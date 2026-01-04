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
// Breve repaso de la estructura. Destacar ingeniería de datos.
#slide(title: "Objetivos de la Práctica")[
  - *Integración*: Enriquecer los datos registrales con su contexto macroeconómico (Banco Mundial).
  - *Limpieza*: Selección de variables y transformación a tipos adecuados.
  - *Análisis No Supervisado*: Segmentación de empresas (Clustering).
  - *Análisis Supervisado*: Predicción del tipo de sociedad (Clasificación).
  - *Validación*: Contraste de hipótesis geográfico.
]

// --- LIMPIEZA ---

// GUION:
// 1. Categorías: Optimización de memoria.
// 2. Fechas: desde texto
// 3. Booleanos: Mapeo explícito.
// 4. Ruido: Eliminación de IDs.
#slide(title: "Código: Limpieza")[
  #text(size: 15pt)[
  ```python
  # Definimos columnas con baja cardinalidad para optimizar memoria
  category_cols = ["Estado de la matrícula", "Tipo de Sociedad", ...]
  df[category_cols] = df[category_cols].astype("category")
  # ... 
  # Conversión de fechas
  date_cols = ["Fecha de Matrícula", "Fecha de Vigencia", ...]
  df[date_cols] = df[date_cols].apply(pd.to_datetime, errors="coerce")
  # ...
  # Mapeo manual de booleanos y eliminación de ruido
  bool_cols = ["Emprendimiento Social", "Extinción de Dominio"]
  df[bool_cols] = df[bool_cols].apply(lambda s: s.map({"S": True, "N": False}))
  # Elimina fecha de cancelacion por alto numero de nulos e identificadores
  df = df.drop(columns=["Fecha de Cancelación", "Número de Matrícula", ...])
  ```
  ]
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
  # Descarga y lectura directa del ZIP desde la API
  url = "https://api.worldbank.org/v2/en/country/COL?downloadformat=csv"
  response = requests.get(url) 
  # ... (Extracción del ZIP en memoria) ...
  wb_source = pd.read_csv(f, skiprows=4)

  target_indicators = {
      'NY.GDP.MKTP.KD.ZG': 'PIB_Crecimiento',
      'FP.CPI.TOTL.ZG': 'Inflacion', ...
  }
  # ... (Filtrado y limpieza de columnas del BM) ...
  # Transformación: De formato 'Ancho' a 'Largo' y luego Pivot
  wb_melted = wb_clean.melt(id_vars=['Indicador'], var_name='Year', ...)
  wb_pivot = wb_melted.pivot(index='Year', columns='Indicador', values='Valor')
  # Integración: Contexto de nacimiento (Left Join por Año Matrícula)
  df = df.merge(wb_pivot.add_suffix('_Matricula'), on='Year_Matricula', how='left')
  ```
  ]
]

// GUION:
// Resultado: Dataset enriquecido.
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
  # ... (Definición de num_features y cat_features) ...
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
  # Eliminar clases con < 2 registros (rompen el stratify)
  v_counts = df_clf[target_col].value_counts()
  df_clf = df_clf[df_clf[target_col].isin(v_counts[v_counts >= 2].index)]
  # ... (Preprocesamiento con ColumnTransformer) ...
  # Split estratificado
  X_train, X_test, y_train, y_test = train_test_split(..., stratify=y)
  # Random Forest con pesos balanceados para mitigar desbalanceo
  model_rf = RandomForestClassifier(
      n_estimators=200, 
      class_weight="balanced", # CRÍTICO: Penaliza error en clases minoritarias
      n_jobs=-1
  )
  model_rf.fit(X_train, y_train)
  ```
  ]
]

// GUION:
// Importancia de variables: Inflación y Ubicación arriba.
#slide(title: "Predicción de Tipo de Sociedad (Resultados)")[
  *Modelo*: Random Forest Classifier.
  
  #align(center)[#image("assets/clasificacion.png", width: 70%)]
  
  *Conclusiones*: La ubicación (Cámara de Comercio) y la *Inflación* al momento de registro son los predictores más potentes.
]

// --- HIPÓTESIS ---

// GUION:
// 1. Preprocesamiento: Agrupamos cámaras pequeñas en "Otras" para cumplir la condición
//    de frecuencias esperadas > 5.
// 2. Residuos: El p-valor solo dice "hay relación". Calculamos los residuos para saber
//    DÓNDE está la relación (qué región prefiere qué sociedad).
#slide(title: "Código: Prueba Chi-Cuadrado")[
  #text(size: 16pt)[
  ```python
  # Agrupación de colas largas para validez estadística
  top_camaras = df['Cámara'].value_counts().nlargest(10).index
  df['Region_Agrupada'] = df['Cámara'].apply(
      lambda x: x if x in top_camaras else 'Otras Regiones'
  )
  # Agrupar Tipos de Sociedad: Mantener los que tengan > 1% de datos, resto a 'Otros'
  threshold = len(df_chi) * 0.01
  soc_counts = df_chi['Tipo de Sociedad'].value_counts()
  valid_socs = soc_counts[soc_counts > threshold].index
  df_chi['Sociedad_Agrupada'] = df_chi['Tipo de Sociedad'].apply(lambda x: x if x in valid_socs else 'Otros Tipos')
  # ... (Creación de tabla de contingencia) ...
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

#slide(title: "Conclusiones Generales")[
  - *Éxito en la Integración*: Las variables macroeconómicas demostraron ser señales predictivas reales, no ruido.

  - *Singularidad Regional*: El tejido empresarial no es homogéneo; Antioquia y Montería requieren análisis diferenciados.

  - *Desafío de Datos*: El desbalanceo masivo hacia "Sociedad Comercial" (90%) es el principal reto técnico.
]

#focus-slide()[Gracias]