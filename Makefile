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


# manuscript/figures/frequentist_uncertainty-1.pdf \
# manuscript/figures/bayesian_model-1.pdf \
# manuscript/figures/bayesian_area-1.pdf
figures: manuscript/figures/pareto_demo-1.pdf \
manuscript/figures/predict_censor-1.pdf


manuscript/figures/pareto_demo-1.pdf: scripts/00_simulation.R
	Rscript $<

manuscript/figures/predict_censor-1.pdf: scripts/01_censoring.R
	Rscript $<

manuscript/figures/%.pdf: scripts/simulation.R
	cd scripts && Rscript ../$<

manuscript: manuscript/manuscript.pdf

manuscript/manuscript.pdf: manuscript/manuscript.tex manuscript/pareto-lakes.bib
	cd manuscript && pdflatex manuscript.tex
	cd manuscript && bibtex manuscript

manuscript/manuscript.bbl: manuscript/manuscript.tex manuscript/pareto-lakes.bib
	cd manuscript && pdflatex manuscript.tex
	cd manuscript && bibtex manuscript

clean:
	-rm -rf manuscript/figures
	-rm arxiv_submission.zip
	-rm manuscript/manuscript.bbl
	-rm data/y.rds data/hydrolakes.rds \
		data/pareto_bayes.rds data/alphas.rds data/area_bayes.rds 
