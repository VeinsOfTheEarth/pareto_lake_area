## Quantifying uncertainty in Pareto estimates of global lake area

[![Paper DOI](https://img.shields.io/badge/Paper-DOI-blue.svg)](https://doi.org) [![Code DOI](https://img.shields.io/badge/Code-10.5281/zenodo.7459226-blue.svg)](https://doi.org/10.5281/zenodo.7459226)

Code and data for the publication:

> **Stachelek, J.**, *Under Revision* Quantifying uncertainty in Pareto estimates of global lake area.

### Products

Manuscript: [manuscript/manuscript.pdf](manuscript/manuscript.pdf)

Stan model: [pareto_model.stan](pareto_model.stan)

<img src="manuscript/figures/stan.png" alt="stan model" width="800"/>

### Reproducibility

```shell
conda create -n paretolakes
conda env update -f environment.yml
source activate paretolakes
Rscript -e "install.packages(c('tidybayes', 'cowplot'), repos='https://cloud.r-project.org')"
```

### Release

This software has been approved for open source release and has been assigned identifier **C23005**.

### Copyright

© 2022. Triad National Security, LLC. All rights reserved.
This program was produced under U.S. Government contract 89233218CNA000001 for Los Alamos National Laboratory (LANL), which is operated by Triad National Security, LLC for the U.S. Department of Energy/National Nuclear Security Administration. All rights in the program are reserved by Triad National Security, LLC, and the U.S. Department of Energy/National Nuclear Security Administration. The Government is granted for itself and others acting on its behalf a nonexclusive, paid-up, irrevocable worldwide license in this material to reproduce, prepare derivative works, distribute copies to the public, perform publicly and display publicly, and to permit others to do so.
