# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

A workspace for turning OBS screen-capture recordings of online university lectures into
structured Typst lecture notes ("конспекты"). It is not a software project: no git, no
build system, no tests. The unit of work is one lecture, and the deliverable is a single
`lecture.typ` per lecture directory.

## Layout

- `template.typ` — shared Typst template, imported by every `lecture.typ`.
- `<course>/<NN>/` — one directory per lecture, grouped by course:
  - `sad/` — «Статистический анализ данных»
  - `moio/` — «Методы оптимизации и исследование операций»
  - Lectures numbered `01/`, `02/`, …
- Root `*.mp4` (e.g. `2026-09-01 13-33-15.mp4`) — raw OBS captures.

Each lecture directory holds **inputs**:
- `transcript.txt` — Whisper transcript, lines `[start-end]  text`, Russian.
- `1.png … N.png` — slide screenshots in presentation order (numbering may drift from the
  deck's own page numbers and may have gaps — e.g. `moio/01/` has no `22.png`).
- `lecture.ogg`, `output*.mp4` — extracted audio / trimmed video.

and the **output**: `lecture.typ` (plus `lecture.pdf` after compiling).

## Compiling a lecture note

```
typst compile --root . sad/01/lecture.typ      # -> sad/01/lecture.pdf
typst watch   --root . sad/01/lecture.typ
```

`--root .` (the repo root) is required: `lecture.typ` does `#import "../../template.typ"`
(the template is one shared copy at the repo root, not per-course), which escapes the
default project sandbox otherwise. Typst is v0.15.1; the bundled "New Computer Modern"
font is used, so no font install is needed.

## template.typ API

`#import "../../template.typ": *` then `#show: doc => lecture(title:, course:, number:, date:, doc)`.

- `lecture(...)` — page setup, title block, running header, heading styling.
- `definition(body, title: none)`, `theorem(...)`, `lemma(...)`, `example(...)` — auto-numbered
  colored callout boxes. Call as `#definition(title: [Данные])[текст]`.
- `note(body)` — grey "Устное пояснение:" box. Use for material the lecturer said aloud that
  is **not** on any slide.
- `neq(content, label-name: none)` — right-numbered display equation with optional label;
  the template disables Typst's built-in equation numbering in favor of this.
- `slide-image(path, caption:, width: 80%)` — figure with "Слайд" supplement. **Do not use it
  directly from a lecture file** (see gotcha below).

### Gotcha: image paths

`slide-image` / `image()` inside `template.typ` resolve relative paths against `template.typ`
(the repo root), not against the lecture file — so `"2.png"` is looked up in the repo root and
fails. Established fix, used in `sad/01/lecture.typ`: define a local helper in the lecture file
so `image()` is called there and paths resolve next to it:

```typ
#let slide-fig(path, caption: none, width: 80%) = figure(
  image(path, width: width), caption: caption, supplement: "Слайд",
)
```

### Gotcha: math in this Typst version (0.15.1)

- `cases(...)` splits its argument list on **every literal comma**, so a range written
  `i = 1, ..., m` inside `cases()` silently becomes extra (broken) rows. Inside `cases()`
  write ranges without commas (`i = 1 ... m`) or escape them (`overline(1\,m)`); commas in
  plain `$...$` are fine.
- `angle.l` / `angle.r` are **not defined** — "unknown symbol modifier". For a scalar
  product write `bold(c)^T bold(x)` (or literal `⟨ ⟩`).
- `#h(...)` immediately followed by `(` in math parses as a call — put a space or use `quad`.

## Writing conventions for lecture.typ

- Match transcript segments to slides **by topic**, not by index — slide timing is not synced
  to the transcript.
- Slides are authoritative for terms, definitions, formulas, theorems, tables, and code — copy
  them verbatim. When the transcript's wording disagrees with a slide, follow the slide.
- Prose, explanations, and transitions come from the transcript, stripped of filler
  ("ну", "то есть", repeats, off-topic remarks).
- Oral-only points → `#note[...]`. Slide diagrams that don't survive prose → embed the PNG via
  the local `slide-fig` helper instead of describing them.
- Headings (`=`, `==`, `===`) mirror the slides' section structure.
- Whisper transcripts here degrade into hallucinated filler — trailing runs of
  "Добавил субтитры DimaTorzoK", "Субтитры создавал DimaTorzok", "Продолжение следует", and
  sometimes an entire file of it (see the opening of `moio/01/transcript.txt`). Ignore those
  lines entirely.
