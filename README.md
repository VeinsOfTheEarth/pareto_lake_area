Code and data for:

## Greater paper title

> Journal Target: The Best Journal

### Products

Figures: [manuscript/figures.pdf](manuscript/figures.pdf)

Appendix: [manuscript/appendix.pdf](manuscript/appendix.pdf)

Manuscript: [manuscript/draft.pdf](manuscript/draft.pdf)

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
