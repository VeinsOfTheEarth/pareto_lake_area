[![Paper DOI](https://img.shields.io/badge/Paper-DOI-blue.svg)](https://doi.org) [![Code DOI](https://img.shields.io/badge/Code-DOI-blue.svg)](https://doi.org/)

Code and data for:

## Quantifying uncertainty in Pareto estimates of global lake area

### Products

Manuscript: [manuscript/manuscript.pdf](manuscript/manuscript.pdf)

<!--- [Notes Scratch-pad](https://docs.google.com/document/d/1ks71d9FZYyjgkdFlzzFcGP2AVxJ-hFSeCDLOytpufoc/edit?usp=sharing) --->

### Reproducibility

```shell
conda create -n paretolakes
conda env update -f environment.yml
source activate paretolakes
Rscript -e "install.packages(c('tidybayes', 'cowplot'), repos='https://cloud.r-project.org')"
```
