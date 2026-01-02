#import "@preview/typslides:1.3.0": *

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

#slide(title: "Objetivos de la Práctica")[
  - *Integración*: Enriquecer los datos registrales con contexto macroeconómico (Banco Mundial).

  - *Limpieza*: Estandarización de fechas y manejo de desbalanceo de clases.

  - *Análisis No Supervisado*: Segmentación de empresas (Clustering).

  - *Análisis Supervisado*: Predicción del tipo de sociedad (Clasificación).

  - *Validación*: Contraste de hipótesis geográfico.
]

#slide(title: "Integración de Datos")[
  *Fuente Externa*: API del Banco Mundial.
  
  *Variables Clave*:
  - Crecimiento del PIB anual.
  - Inflación (IPC).
  - Tasa de desempleo.

  *Estrategia de Cruce*:
  Se realizó un `Left Join` utilizando el *Año de Matrícula* para capturar las condiciones económicas del momento de fundación de cada empresa.
]

#slide(title: "Segmentación Regional (Clustering)")[
  *Modelo*: K-Means (k=4) + PCA (Reducción de dimensionalidad).
  
  #align(center)[#image("assets/cluster.png", width: 70%)]
  
  *Hallazgo*: Existencia de un "Cluster Base" (70% de datos) y una anomalía estructural en *Antioquia* (Cluster 2).
]

#slide(title: "Predicción de Tipo de Sociedad")[
  *Modelo*: Random Forest Classifier.
  
  #align(center)[#image("assets/clasificacion.png", width: 70%)]
  
  *Insight*: La ubicación (Cámara de Comercio) y la *Inflación* al momento de registro son los predictores más potentes.
]

#slide(title: "Contraste de Hipótesis")[
  *Prueba*: Chi-Cuadrado de Pearson.
  *Hipótesis*: Dependencia entre Región y Tipo de Sociedad.
  
  #align(center)[#image("assets/heatmap_chi.png", width: 65%)]
  
  *Resultado*: $p < 0.05$. Se rechaza la independencia. Montería y Medellín muestran desviaciones significativas del comportamiento nacional.
]

#slide(title: "Conclusiones")[
  - *Éxito en la Integración*: Las variables macroeconómicas demostraron ser señales predictivas reales, no ruido.

  - *Singularidad Regional*: El tejido empresarial no es homogéneo; Antioquia y Montería requieren análisis diferenciados.

  - *Desafío de Datos*: El desbalanceo masivo hacia "Sociedad Comercial" (90%) limita la precisión en clases minoritarias sin técnicas de resampling agresivas.
]

#focus-slide()[Gracias]