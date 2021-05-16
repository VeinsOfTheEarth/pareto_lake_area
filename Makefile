.PHONY: figures manuscript all

all: figures manuscript arxiv_submission.zip

arxiv_submission.zip: manuscript/manuscript.tex \
manuscript/jsta.bst \
manuscript/orcid.pdf \
manuscript/arxiv.sty \
manuscript/manuscript.bbl
	zip -j $@ $^
	mkdir figures
	cp -r manuscript/figures/*.pdf figures
	zip -u $@ figures/*.pdf
	rm -rf figures

figures: manuscript/figures/pareto_demo-1.pdf \
manuscript/figures/predict_area-1.pdf \
manuscript/figures/frequentist_uncertainty-1.pdf \
manuscript/figures/bayesian_model-1.pdf \
manuscript/figures/bayesian_area-1.pdf

manuscript/figures/%.pdf: scripts/simulation.R
	cd scripts && Rscript ../$<

manuscript: manuscript/manuscript.pdf

manuscript/manuscript.%: manuscript/manuscript.tex manuscript/pareto-lakes.bib
	cd manuscript && pdflatex manuscript.tex
	cd manuscript && bibtex manuscript

clean:
	-rm -rf figures
	-rm arxiv_submission.zip
	-rm manuscript/manuscript.bbl
