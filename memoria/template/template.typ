// Portada

// --- Table of Contents ---
#let toc() = {
  // No numerar esta página
  set page(numbering: none)

  // Encabezados principales en negrita (para el índice)
  show outline.entry.where(
    level: 1,
  ): it => {
    v(12pt, weak: true)
    strong(text(it))
  }

  context {
    outline(
      // Genera indice
      indent: 2em,
    )
  }
}

#let cover(
  title: "Ejemplo",
  author: "Fulanito",
  female_author: false,
) = {
  set align(center + horizon)
  set block(width: 100%)
  // No numerar esta página
  set page(numbering: none)
  place(
    top + center,
    image(
      "Logo_UOC.svg",
      alt: "Logo de la UOC",
      width: 35%,
    ),
    float: true,
  )
  block(height: 13%)[
    #text(weight: "bold", size: 24pt)[
      Master Universitario en ciencia de datos]
  ]
  line(length: 100%)
  block(height: 26%)[
    #text(weight: "bold", size: 30pt)[
      #title]
  ]
  line(length: 100%)
  block(height: 12%)[
    #align(right)[
      #set text(size: 16pt)
      #if female_author [Alumna] else [Alumno]: #author
    ]]
  pagebreak(weak: true)
}


#let ok = rgb("#c2f7a1")
#let error = rgb("#f7a1a1")
#let emph-box(body, color: luma(230)) = {
  set text(size: 0.8em, weight: "extrabold", baseline: -0.1em)
  box(
    body,
    fill: color,
    height: 1.3em,
    inset: 0.4em,
    radius: 12pt,
    baseline: 0.3em,
    stroke: 0.5pt + black,
  )
}

#let template(
  title: "Ejemplo",
  author: "Fulanito",
  female_author: false,
  bibliography_path: none,
  doc,
) = [
  #set text(lang: "es")
  #set page(paper: "a4", numbering: "1")
  #set text(font: "Liberation Serif", size: 12pt)
  #set heading(numbering: "1.1.")
  #set table(inset: 0.6em, stroke: (x, y) => (
    // Only draw top stroke if we're beyond the first row
    // Avoid conflicting with the outer block stroke
    top: if y > 0 { black },
    // Only draw left stroke if we're beyond the first column
    // Avoid conflicting with the outer block stroke
    left: if x > 0 { black },
    // No bottom or right stroke so that cells at the last row
    // or last column don't generate stroke conflicting with
    // the block outer stroke
  ))
  #show table: it => block(
    it,
    // block will provide stroke with radius around the table
    // we have to ensure the table doesn't fight it with its own stroke
    stroke: 1.2pt + black,
    radius: 5pt,
    inset: 0.08em,
  )

  #set list(marker: (
    [
      #set line(stroke: (cap: "round", thickness: 1.2pt))
      #box(
        stack(
          line(length: 0.55em, angle: 25deg, start: (0em, -0.45em)),
          line(length: 0.35em, angle: 0deg, start: (0em, 0em)),
          line(length: 0.55em, angle: -25deg, start: (0em, 0.45em)),
        ),
        baseline: 0.75em,
      )],
    box(
      circle(fill: none, stroke: 1pt + black, width: 0.4em),
      baseline: 0.55em,
    ),
  ))
  #cover(
    title: title,
    author: author,
    female_author: female_author,
  )
  #toc()
  #counter(page).update(1)
  #doc
  #if bibliography_path != none [
    #bibliography(bibliography_path, style: "ieee")
  ]
]


