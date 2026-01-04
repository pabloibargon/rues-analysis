#import "template/template.typ": template
#import "@preview/zebraw:0.5.5": *
#show: zebraw

#show: template.with(
  title: [Práctica 2

    Tipología y ciclo de vida de los datos],
  author: "Pablo Ibarlucea González y Oscar Javier Bachiller Sandoval",
  bibliography_path: "/bibliografia.bib",
)
= Descripción del dataset

El conjunto de datos que corresponde al desarrollo de esta práctica, proviene de la extracción realizada mediante técnicas de _web scraping_ sobre el portal del Registro Único Empresarial y Social (RUES) de Colombia #cite(label("rues")), actividad desarrollada en la práctica 1, considerando que la importancia de este dataset radica en su capacidad para ofrecer una radiografía actual del tejido empresarial formal en diversas regiones del país, permitiendo analizar patrones de constitución, formalización y supervivencia de las organizaciones.

El archivo original cuenta con 4377 registros y 17 columnas, teniendo presente que las variables capturadas incluyen identificadores únicos (NIT), ubicación geográfica (*Cámara de Comercio*), información temporal (*Fecha de Matrícula*, *Renovación*, *Cancelación*) y categorización jurídica (*Tipo de Sociedad*, *Tipo de Organización*).

El problema analítico que se pretende abordar consiste en determinar si existen factores estructurales, tanto geográficos como macroeconómicos, que condicionen la elección del tipo societario y la supervivencia de las empresas, dónde, para responder a esto, se hace necesario enriquecer la información registral, que es de carácter administrativo, con datos del contexto económico.

= Integración y selección

Para dotar de contexto explicativo a los registros administrativos, decidimos integrar datos macroeconómicos externos procedentes del Banco Mundial #cite(label("worldbank")), esta decisión se justifica por la hipótesis de que las condiciones económicas del momento de fundación (año de matrícula) influyen en la estructura legal adoptada por la empresa.

El proceso de integración se realizó mediante un script en Python que consume directamente la API del Banco Mundial, dónde se seleccionaron cinco indicadores clave: crecimiento del PIB anual, inflación al consumidor, tasa de desempleo total, tasa de interés para préstamos y remesas como porcentaje del PIB; estos datos, originalmente en formato "ancho" (años como columnas), fueron transformados mediante una operación de _pivot_ para alinearlos con la estructura tabular requerida.

Se cruzó el año de la *Fecha de Matrícula* con los indicadores económicos para capturar el entorno de nacimiento de la empresa, el resultado es un dataset enriquecido donde cada empresa no solo tiene sus atributos legales, sino también una "foto" económica de su nacimiento.

= Limpieza de datos

La fase de limpieza fue crítica debido a la naturaleza heterogénea de los datos extraídos de la web, dado se identificaron inconsistencias en los formatos de fecha y cadenas de texto no estandarizadas.

En primer lugar, las columnas temporales (*Fecha de Matrícula*, *Vigencia*, etc.) se convirtieron al formato `datetime`, posteriormente, se observó que una proporción significativa de registros carecía de fechas válidas o presentaba el valor "Indefinido" en la vigencia, para estos casos se gestionaron extrayendo únicamente el año para los cruces, imputando con cero o descartando registros cuando la fecha de matrícula era inexistente, ya que es una variable indispensable para la integración económica.

Respecto a las variables categóricas, se detectó un desbalance severo en la variable objetivo *Tipo de Sociedad*, puesto, la clase "Sociedad Comercial" representa cerca del 90% de los datos, mientras que categorías como "Economía solidaria" tenían una presencia casi anecdótica. Para los análisis supervisados y las pruebas de hipótesis, se aplicaron filtros para excluir clases con menos de dos instancias, evitando errores en la estratificación durante la división de conjuntos de entrenamiento y prueba, así mismo, para la prueba Chi-cuadrado, se agruparon las regiones minoritarias bajo la etiqueta "Otras Regiones" y los tipos societarios poco frecuentes bajo "Otros Tipos", asegurando de esta manera la robustez estadística de los resultados.

= Análisis de los datos

El análisis se estructuró en tres enfoques complementarios: segmentación no supervisada, clasificación supervisada y contraste de hipótesis.

== Segmentación Regional (Clustering)
Se aplicó el algoritmo K-Means combinado con una reducción de dimensionalidad PCA (Análisis de Componentes Principales). el objetivo fue identificar agrupaciones naturales de empresas basadas en su ubicación y las condiciones económicas de su fundación, para lo cual se determinó un número óptimo de 4 clústeres.

Los resultados mostraron un *Cluster 3* predominante que agrupa a más del 70% de las empresas, definiendo un "perfil base" nacional, sin embargo, se detectaron anomalías regionales: el *Cluster 2* tiene una presencia significativa en Antioquia (39%), sugiriendo un ecosistema empresarial distintivo, mientras que el *Cluster 0* destaca en regiones como Montería y Chocó, las métricas de validación ($"Silhouette Score" = 0.36$, $"Calinski-Harabasz" = 2302$) indican una estructura con centros densos pero fronteras difusas.

== Clasificación Supervisada
Se entrenó un modelo _Random Forest_ para predecir el *Tipo de Sociedad*, a pesar de obtener una exactitud general del 63.82%, el análisis detallado reveló dificultades asociadas al desbalanceo de clases anteriormente indicado, considerando que el modelo logró un alto _recall_ (90%) para la clase minoritaria "Sociedad Civil", pero con una precisión muy baja, generando numerosos falsos positivos.

El hallazgo más relevante de este modelo fue la importancia de las variables predictoras, la variable *Cámara de Comercio (Medellín)* y los indicadores económicos (*Inflación*, *PIB* al momento de matrícula) resultaron ser los predictores más influyentes, validando que el origen geográfico y el ciclo económico determinan la forma jurídica.

== Contraste de Hipótesis
Finalmente, se aplicó una prueba Chi-cuadrado de Pearson para evaluar la independencia entre la región (*Cámara de Comercio*) y el *Tipo de Sociedad*, se obtuvo un valor-p virtualmente nulo ($p < 0.05$), rechazando la hipótesis de independencia, por otro lado, el mapa de calor de residuos estandarizados confirmó desviaciones significativas: Montería mostró un exceso de entidades sin ánimo de lucro, mientras que Antioquia presentó una preferencia superior a la esperada por la sociedad civil y comercial.

= Representación de los resultados

Las visualizaciones generadas permitieron interpretar la complejidad de los modelos.

#figure(
  image("assets/cluster.png"),
  caption: [Proyección en 2D de los clústeres empresariales identificados.],
)

La proyección PCA evidenció cómo, aunque existe una gran masa central de empresas homogéneas, ciertos grupos se separan en función de la varianza explicada por las condiciones económicas y geográficas. Por otro lado, la matriz de confusión del modelo de clasificación ilustró visualmente el desafío del desbalanceo, mostrando una clara tendencia del modelo a favorecer la clase mayoritaria.

#figure(
  image("assets/clasificacion.png"),
  caption: [Variables más relevantes para la predicción del tipo de sociedad.],
)

El gráfico de importancia de variables fue fundamental para confirmar que la inflación y el desempleo no son ruido, sino señales determinantes en la caracterización de las empresas.

#figure(
  image("assets/heatmap_chi.png"),
  caption: [Mapa de calor de residuos estandarizados (Prueba Chi-Cuadrado).],
)

Finalmente, la visualización de los residuos estandarizados ofrece una interpretación espacial de la dependencia estadística detectada, a diferencia de un simple valor-p, este gráfico permite identificar las celdas específicas responsables de la asociación: los colores intensos señalan dónde la realidad se desvía drásticamente del modelo teórico de independencia, confirmando visualmente las singularidades del tejido empresarial en regiones como Montería (exceso de entidades sin ánimo de lucro) y Antioquia (preferencia por la sociedad civil).

= Resolución del problema

El análisis realizado permite concluir que el tejido empresarial colombiano no es uniforme, la integración de datos macroeconómicos demostró ser una estrategia efectiva, ya que las variables derivadas del Banco Mundial figuraron entre los principales predictores del comportamiento societario.

Se responde afirmativamente al problema planteado: existen diferencias estructurales significativas dependientes de la región y del momento económico, considerando que las políticas de fomento empresarial o formalización no deberían ser homogéneas, dado que regiones como Antioquia o Montería exhiben dinámicas de constitución legal que difieren estadísticamente del estándar nacional (representado por Bogotá y otras capitales), así, el modelo predictivo, aunque perfectible en términos de precisión para clases minoritarias, validó la capacidad de anticipar el perfil legal de una empresa basándose únicamente en su contexto espacio-temporal.

= Codigo

Se ha realizado el análisis en un cuaderno de jupyter que se incluye completamente al final de la memoria.

= Video

El enlace al video en el que se presenta la práctica: 

= Contribuciones

#figure(
  table(
    columns: 2,
    table.header()[*Contribuciones*][*Firma*],
    [Investigación previa],
    [Pablo Ibarlucea González, Oscar Javier Bachiller Sandoval],

    [Redacción de las respuestas],
    [Pablo Ibarlucea González, Oscar Javier Bachiller Sandoval],

    [Desarrollo del código],
    [Pablo Ibarlucea González, Oscar Javier Bachiller Sandoval],

    [Participación en el vídeo],
    [Pablo Ibarlucea González, Oscar Javier Bachiller Sandoval],
  ),
  caption: [
    Tabla de contribuciones
  ],
)
