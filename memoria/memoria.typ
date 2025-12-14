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

= Integración y selección

= Limpieza de datos

= Análisis de los datos

= Representación de los resultados

= Resolución del problema

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
