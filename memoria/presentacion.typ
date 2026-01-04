#import "@preview/typslides:1.3.0": *
#import "@preview/zebraw:0.5.5": *
#show: zebraw

#show: typslides.with(
  ratio: "16-9",
  theme: "darky",
  font: "Noto Sans Deseret",
  font-size: 20pt,
  link-style: "both",
  show-progress: true,
)

#front-slide(
  title: "RUES Análisis",
  authors: "Pablo Ibarlucea González y Oscar Javier Bachiller Sandoval",
  info: [#link("https://github.com/pabloibargon/rues-analysis")],
)

// GUION:
// Breve repaso de la estructura de la presentación.
// Destacar que no es solo análisis, sino ingeniería de datos (integración).
#slide(title: "Objetivos de la Práctica")[
  - *Integración*: Enriquecer los datos registrales con contexto macroeconómico (Banco Mundial).
  - *Limpieza*: Estandarización de fechas y manejo de desbalanceo de clases.
  - *Análisis No Supervisado*: Segmentación de empresas (Clustering).
  - *Análisis Supervisado*: Predicción del tipo de sociedad (Clasificación).
  - *Validación*: Contraste de hipótesis geográfico.
]

// --- INTEGRACIÓN ---

// GUION:
// 1. Automatización: Usamos la API directa, asegurando datos actualizados sin descargar CSVs manuales.
// 2. Selección de indicadores: PIB, Inflación, Desempleo (Variables macro que afectan decisiones de negocio).
// 3. Transformación CLAVE: Los datos vienen "anchos" (años como columnas). Hacemos melt/pivot
//    para tener el AÑO como índice y poder hacer el JOIN con la fecha de matrícula de la empresa.
#slide(title: "Código: Ingesta Banco Mundial")[
  #text(size: 16pt)[
  ```python
  url = "https://api.worldbank.org/v2/en/country/COL?downloadformat=csv"
  response = requests.get(url) # Descarga directa del ZIP

  target_indicators = {
      'NY.GDP.MKTP.KD.ZG': 'PIB_Crecimiento',
      'FP.CPI.TOTL.ZG': 'Inflacion', ...
  }

  # Transformación: De formato 'Ancho' a 'Largo' y luego Pivot
  # Objetivo: Tener [Año, PIB, Inflacion, ...]
  wb_melted = wb_clean.melt(id_vars=['Indicador'], var_name='Year', ...)
  wb_pivot = wb_melted.pivot(index='Year', columns='Indicador', values='Valor')
  
  # Integración: Contexto de nacimiento (Año Matrícula)
  df = df.merge(wb_pivot.add_suffix('_Matricula'), on='Year_Matricula', how='left')
  ```
  ]
]

// GUION:
// Resumir el resultado del proceso anterior.
// Ahora cada fila del dataset original tiene pegada la "foto económica" del país
// en el momento en que esa empresa nació.
#slide(title: "Integración de Datos (Resultados)")[
  *Fuente Externa*: API del Banco Mundial.
  
  *Variables Clave Agregadas*:
  - Crecimiento del PIB anual.
  - Inflación (IPC).
  - Tasa de desempleo.

  *Estrategia*: `Left Join` utilizando el *Año de Matrícula*.
]

// --- CLUSTERING ---

// GUION:
// 1. Pipeline: Usamos Sklearn Pipeline para encapsular todo el proceso.
// 2. Preprocesamiento: StandardScaler es OBLIGATORIO en K-Means (sensible a distancias).
// 3. PCA: Reducimos a 2 dimensiones para poder generar
//    el gráfico de dispersión que veremos a continuación.
#slide(title: "Código: Pipeline de Clustering")[
  #text(size: 16pt)[
  ```python
  # Preprocesamiento diferenciado numérico/categórico
  preprocessor = ColumnTransformer(transformers=[
      ('num', StandardScaler(), num_features), 
      ('cat', OneHotEncoder(), cat_features)
  ])

  # Pipeline: Limpieza -> PCA (Reducción) -> Modelo
  pipeline = Pipeline([
      ('preprocessor', preprocessor),
      ('pca', PCA(n_components=2)), 
      ('kmeans', KMeans(n_clusters=4, random_state=44))
  ])

  pipeline.fit(df_model)
  
  # Guardamos coordenadas PCA para visualización
  df_model['Cluster'] = pipeline.named_steps['kmeans'].labels_
  ```
  ]
]

// GUION:
// Interpretar el gráfico.
// - La gran mancha central (Cluster 3) es el comportamiento estándar (Bogotá, etc.).
// - Señalar la anomalía verde azulada (Cluster 2): Corresponde mayoritariamente a Antioquia.
// - Conclusión: Las empresas en Antioquia tienen características estructurales distintas.
#slide(title: "Segmentación Regional (Visualización)")[
  *Modelo*: K-Means (k=4) + PCA.
  
  #align(center)[#image("assets/cluster.png", width: 70%)]
  
  *Conclusiones*: Existencia de un "Cluster Base" (70% de datos) y una anomalía estructural en *Antioquia* (Cluster 2).
]

// --- CLASIFICACIÓN ---

// GUION:
// 1. Problema de Desbalanceo: 90% son Sociedades Comerciales. Si no hacemos nada,
//    el modelo predice siempre "Comercial" y acierta el 90%, pero es inútil.
// 2. Solución 1: Stratify en el split para asegurar que el test set tenga clases raras.
// 3. Solución 2: class_weight="balanced" para penalizar al modelo si se equivoca en las clases pequeñas.
#slide(title: "Código: Clasificación Supervisada")[
  #text(size: 15pt)[
  ```python
  # 1. Filtro: Eliminar clases con < 2 registros (rompen el stratify)
  v_counts = df_clf[target_col].value_counts()
  df_clf = df_clf[df_clf[target_col].isin(v_counts[v_counts >= 2].index)]

  # 2. Split estratificado (Mantiene proporción de clases)
  X_train, X_test, y_train, y_test = train_test_split(..., stratify=y)

  # 3. Random Forest con pesos balanceados
  model_rf = RandomForestClassifier(
      n_estimators=200, 
      class_weight="balanced", # CRÍTICO para datos desbalanceados
      n_jobs=-1
  )
  model_rf.fit(X_train, y_train)
  ```
  ]
]

// GUION:
// Mirar el gráfico de barras a la derecha.
// Lo más importante: Las variables del Banco Mundial (Inflación, PIB) aparecen en el top.
// Esto valida que el esfuerzo de integración valió la pena: la economía afecta el tipo de sociedad.
// La ubicación (Medellín) también es predictor top, confirmando lo visto en clustering.
#slide(title: "Predicción de Tipo de Sociedad (Resultados)")[
  *Modelo*: Random Forest Classifier.
  
  #align(center)[#image("assets/clasificacion.png", width: 70%)]
  
  *Conclusiones*: La ubicación (Cámara de Comercio) y la *Inflación* al momento de registro son los predictores más potentes.
]

// --- HIPÓTESIS ---

// GUION:
// 1. No podemos aplicar Chi-Cuadrado a ciegas.
// 2. Preprocesamiento: Agrupamos cámaras pequeñas en "Otras" para cumplir la condición
//    de frecuencias esperadas > 5.
// 3. Residuos: El p-valor solo dice "hay relación". Calculamos los residuos para saber
//    DÓNDE está la relación (qué región prefiere qué sociedad).
#slide(title: "Código: Prueba Chi-Cuadrado")[
  #text(size: 16pt)[
  ```python
  # Agrupación de colas largas para validez estadística
  top_camaras = df['Cámara'].value_counts().nlargest(10).index
  df['Region_Agrupada'] = df['Cámara'].apply(
      lambda x: x if x in top_camaras else 'Otras Regiones'
  )

  # Tabla de contingencia: Región vs Tipo Sociedad
  contingency_table = pd.crosstab(df['Region_Agrupada'], df['Sociedad_Agrupada'])

  # Test estadístico
  chi2, p_val, dof, expected = stats.chi2_contingency(contingency_table)
  
  # Cálculo de Residuos Estandarizados (Para el Heatmap)
  residuals = (contingency_table - expected) / np.sqrt(expected)
  ```
  ]
]

// GUION:
// Interpretar el Heatmap (Azul = Más de lo esperado, Rojo = Menos).
// - Cuadro Rojo oscuro en Montería/Entidad sin ánimo de lucro: Exceso masivo.
// - Cuadro Azul en Medellín/Sociedad Civil: Preferencia única por esta figura.
// - P-Valor cercano a 0 confirma que esto no es aleatorio.
#slide(title: "Contraste de Hipótesis (Visualización)")[
  *Prueba*: Chi-Cuadrado de Pearson.
  *Hipótesis*: Dependencia entre Región y Tipo de Sociedad.
  
  #align(center)[#image("assets/heatmap_chi.png", width: 65%)]
  
  *Resultado*: $p < 0.05$. Se rechaza la independencia. Montería y Medellín muestran desviaciones significativas del comportamiento nacional.
]

// --- CIERRE ---

// GUION:
// Recapitular los 3 hallazgos principales.
// 1. La integración funcionó (variables económicas predicen).
// 2. Colombia no es uniforme (Antioquia/Montería son casos especiales).
// 3. Limitación técnica: El desbalanceo de datos requiere técnicas avanzadas.
#slide(title: "Conclusiones Generales")[
  - *Éxito en la Integración*: Las variables macroeconómicas demostraron ser señales predictivas reales, no ruido.

  - *Singularidad Regional*: El tejido empresarial no es homogéneo; Antioquia y Montería requieren análisis diferenciados.

  - *Desafío de Datos*: El desbalanceo masivo hacia "Sociedad Comercial" (90%) es el principal reto técnico.
]

#focus-slide()[Gracias]