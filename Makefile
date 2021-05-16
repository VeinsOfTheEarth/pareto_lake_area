.PHONY: figures manuscript all

all: figures manuscript

figures: scripts/simulation.R
	cd scripts && Rscript ../$<

manuscript: manuscript/manuscript.pdf

manuscript/manuscript.pdf: manuscript/manuscript.tex manuscript/pareto-lakes.bib
	cd manuscript && pdflatex manuscript.tex
