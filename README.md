Code and data for:

## Greater paper title

> Journal Target: The Best Journal

### Products

Figures: [manuscript/figures.pdf](manuscript/figures.pdf)

Appendix: [manuscript/appendix.pdf](manuscript/appendix.pdf)

Manuscript: [manuscript/draft.pdf](manuscript/draft.pdf)

### Philosophy

There are many existing paper templates. Nearly all of them assume the goal is to create a fully-formed paper integrating text, figures and tables. However, I find that this does not work for submission to most journals where the figures are submitted as separate files. The template herein, creates separate figures, tables, and manuscript text pdfs to faciliate journal submission and sharing with co-authors. 

### Usage

* Git clone as your project name (`git clone https://github.com/jsta/paper_template.git mypaper`)

* Fill-out [README.md](README.md) title, journal target, and reproducibility requirements (using `packrat:::appDependencies()`)

* Define `data`, `figures`, and `tables` targets in [Makefile](Makefile)

* With `make` run `make all`

### Reproducibility

#### Data requirements

#### System requirements

* R
  * `packrat:::appDependencies()`
