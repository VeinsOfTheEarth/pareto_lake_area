.PHONY: figures manuscript all

all: figures manuscript

figures: manuscript/figures/pareto_demo-1.pdf \
manuscript/figures/predict_area-1.pdf \
manuscript/figures/frequentist_uncertainty-1.pdf \
manuscript/figures/bayesian_model-1.pdf \
manuscript/figures/bayesian_area-1.pdf

manuscript/figures/%.pdf: scripts/simulation.R
	cd scripts && Rscript ../$<

manuscript: manuscript/manuscript.pdf

manuscript/manuscript.pdf: manuscript/manuscript.tex manuscript/pareto-lakes.bib
	cd manuscript && pdflatex manuscript.tex
