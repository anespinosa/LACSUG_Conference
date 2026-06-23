README
================
06/24/2026

# Introduction to Social Networks with `netmem`

A [**2-hour hands-on
workshop**](https://github.com/anespinosa/LACSUG_Conference) that
introduces social network analysis through
[`netmem`](https://anespinosa.github.io/netmem/), an R package that
treats every network as a matrix and builds its measures on top of
matrix algebra.

**Author:** 🖊 [Alejandro Espinosa-Rada](https://www.aespinosarada.com) —
Institute of Sociology, Pontificia Universidad Católica de Chile.

## Audience

People new to social networks who can run basic R (assign objects, call
functions, index a matrix). No prior network experience required.

## Contents

| File | What it is |
|----|----|
| `netmem_workshop.Rmd` | The workshop source (R Markdown). Run it chunk by chunk, or render the whole thing. |
| `netmem_workshop.html` | Pre-rendered output — open in any browser to read/follow along. |

## How to run

``` r
install.packages("netmem")    # the measures (from CRAN)
install.packages("igraph")    # canonical analysis + plotting
install.packages("sna")       # canonical analysis from matrices
install.packages("ggraph")    # one polished ggplot-style network plot
install.packages("rmarkdown")

# render the full document to HTML:
rmarkdown::render("netmem_workshop.Rmd")
```

Or just open `netmem_workshop.Rmd` in RStudio and step through it.

## Structure (approx. 20 min per module)

0.  **Setup** — install, load, a small plotting helper.
1.  **A network *is* a matrix** — adjacency vs. incidence, edge-list
    conversions, `matrix_report()`.
2.  **Your first real network** — Krackhardt managers: density, degree,
    reciprocity. *Includes a section reproducing every measure in
    `igraph` and `sna`.*
3.  **Interlude — Drawing networks** — layouts and aesthetics with
    `igraph` and `ggraph` (size = degree, colour = k-core).
4.  **Local structure** — dyad census, transitivity, components,
    k-cores, cliques.
5.  **Ego networks & structural holes** — `ego_net()`, redundancy, Burt
    constraint.
6.  **Homophily** — Lazega lawyers: mixing matrix, E–I index, Blau
    heterogeneity.
7.  **Beyond the simple graph** — two-mode projections, signed
    (structural balance), multilevel meta-matrix.

Each module ends with a *Your turn* exercise and a collapsible solution.

## Canonical packages alongside `netmem`

Throughout, key measures are reproduced with the two standard packages
so attendees can trust the numbers and read code from any ecosystem:

- **`igraph`** — build a graph object once
  (`graph_from_adjacency_matrix()`), then `edge_density()`,
  `reciprocity()`, `degree()`, `dyad_census()`, `transitivity()`,
  `coreness()`, `components()`, `assortativity_nominal()`.
- **`sna`** — reads adjacency matrices directly (like `netmem`):
  `gden()`, `degree()`, `dyad.census()`.

To avoid the `igraph`/`sna` name clashes, functions are called
namespaced (`igraph::`, `sna::`).

## Convert to Quarto

The document is plain R Markdown so it renders with `rmarkdown` +
`pandoc` (no extra tooling). If you have the
[Quarto](https://quarto.org) CLI installed, the same content works as a
`.qmd` with only a YAML tweak.

## Resources

- Package site: <https://anespinosa.github.io/netmem/>

- Source & issues: <https://github.com/anespinosa/netmem>

- Workshop site: <https://github.com/anespinosa/LACSUG_Conference>

- More datasets:
  [`classicnets`](https://github.com/anespinosa/classicnets)

- Podcast [Knitting Networks/Tejiendo
  Redes](https://anchor.fm/tejiendoredes). The bilingual (Spanish and
  English) podcast of Social Network Science, sponsored by the
  *International Network for Social Network Analysis*
  [(INSNA)](https://www.insna.org/news/knitting-networks-podcast).

- The Chilean Society for Social Network Science
  [(CHISOCNET)](https://chisocnet.org): To gain access to the mailing
  list, please contact Alejandro Espinosa-Rada.
