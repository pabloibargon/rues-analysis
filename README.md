# RUES Analysis

Pablo Ibarlucea González y Oscar Javier Bachiller Sandoval

Este repositorio contiene el flujo de trabajo para la limpieza, integración y análisis de datos del Registro Único Empresarial y Social (RUES) de Colombia, enriquecido con indicadores macroeconómicos del Banco Mundial.

## 📂 Estructura

- **`analysis.ipynb`**: Notebook principal. Contiene el pipeline completo:
  - Descarga automática de datos del Banco Mundial.
  - Integración de datasets (Merge).
  - Modelos de Clustering (K-Means + PCA).
  - Clasificación Supervisada (Random Forest).
  - Pruebas estadísticas (Chi-Cuadrado).
- **`dataset/`**: Contiene los datos crudos obtenidos mediante web-scraping.
- **`memoria/`**: Código fuente en Typst y activos para la generación del informe final (`memoria.pdf`).

## 🚀 Instalación y Uso

1. Instalar las dependencias necesarias:
   ```bash
   pip install -r requirements.txt
   ```

2. Ejecutar el notebook:
   Abrir `analysis.ipynb` y ejecutar todas las celdas secuencialmente.
   *Nota: Se requiere conexión a internet para descargar los datos del API del Banco Mundial.*

## 📄 Informe
El análisis detallado, metodología y conclusiones se encuentran compilados en **`memoria/memoria.pdf`**.