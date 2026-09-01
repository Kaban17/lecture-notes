// ============================================================
// template.typ — шаблон конспекта лекции
// Использование: #import "template.typ": *
//                #show: doc => lecture(
//                  title: "Название лекции",
//                  course: "Название курса",
//                  number: 5,
//                  date: "2026-09-01",
//                  doc
//                )
// ============================================================

#let accent = rgb("#2b5fb0")

// ---------- счётчики ----------
#let def-counter = counter("definition")
#let thm-counter = counter("theorem")
#let ex-counter = counter("example")
#let eq-counter = counter("equation-block")

// ---------- базовый блок для окружений ----------
#let boxed-env(kind, counter-ref, body, title: none, color: accent) = {
  counter-ref.step()
  let num = context counter-ref.display()
  block(
    width: 100%,
    fill: color.lighten(92%),
    stroke: (left: 2.5pt + color),
    inset: (left: 12pt, rest: 10pt),
    radius: 2pt,
    breakable: true,
    [
      #text(weight: "bold", fill: color)[
        #kind #context counter-ref.display()
        #if title != none [ (#title)]
        .
      ]
      #h(0.3em)
      #body
    ],
  )
}

// ---------- определение ----------
#let definition(body, title: none) = boxed-env(
  "Определение", def-counter, body, title: title, color: accent,
)

// ---------- теорема / утверждение / лемма ----------
#let theorem(body, title: none) = boxed-env(
  "Теорема", thm-counter, body, title: title, color: rgb("#a13d3d"),
)

#let lemma(body, title: none) = boxed-env(
  "Лемма", thm-counter, body, title: title, color: rgb("#a13d3d"),
)

// ---------- пример ----------
#let example(body, title: none) = boxed-env(
  "Пример", ex-counter, body, title: title, color: rgb("#3d8b5f"),
)

// ---------- устное пояснение (из транскрипта, не со слайда) ----------
#let note(body) = block(
  width: 100%,
  fill: rgb("#f5f5f5"),
  stroke: (left: 2pt + gray),
  inset: (left: 12pt, rest: 9pt),
  radius: 2pt,
  breakable: true,
  [
    #text(style: "italic", fill: gray, size: 0.9em)[Устное пояснение:]
    #h(0.3em)
    #text(style: "italic", size: 0.95em)[#body]
  ],
)

// ---------- нумерованная формула с меткой ----------
#let neq(content, label-name: none) = {
  eq-counter.step()
  [
    #context box(width: 100%)[
      #box(width: 100%)[$ #content $]
      #h(1fr)
      #box[(#context eq-counter.display())]
      #if label-name != none { label(label-name) }
    ]
  ]
}

// ---------- слайд-изображение с подписью ----------
#let slide-image(path, caption: none, width: 80%) = figure(
  image(path, width: width),
  caption: caption,
  supplement: "Слайд",
)

// ---------- основной шаблон документа ----------
#let lecture(
  title: "Название лекции",
  course: none,
  number: none,
  date: none,
  doc,
) = {
  set document(title: title)
  set page(
    paper: "a4",
    margin: (x: 2.2cm, y: 2.5cm),
    numbering: "1",
    header: context {
      if here().page() > 1 [
        #set text(size: 9pt, fill: gray)
        #course #h(1fr) #title
        #line(length: 100%, stroke: 0.5pt + gray)
      ]
    },
  )
  set text(font: "New Computer Modern", lang: "ru", size: 11pt)
  set heading(numbering: "1.1")
  set par(justify: true, leading: 0.65em)
  set math.equation(numbering: none) // используем свою нумерацию через neq()

  show heading.where(level: 1): it => {
    v(0.6em)
    text(size: 16pt, weight: "bold", fill: accent)[#it]
    v(0.3em)
  }
  show heading.where(level: 2): it => {
    v(0.4em)
    text(size: 13pt, weight: "bold")[#it]
    v(0.2em)
  }

  // ---------- титульный блок ----------
  align(center)[
    #if course != none [
      #text(size: 11pt, fill: gray)[#course]
      #v(0.3em)
    ]
    #text(size: 20pt, weight: "bold")[#title]
    #v(0.2em)
    #if number != none or date != none [
      #text(size: 10pt, fill: gray)[
        #if number != none [Лекция #number]
        #if number != none and date != none [ · ]
        #if date != none [#date]
      ]
    ]
  ]
  v(1.2em)

  doc
}

