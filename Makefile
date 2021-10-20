.PHONY: figures manuscript all

# arxiv_submission.zip
all: figures manuscript 

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


# manuscript/figures/bayesian_model-1.pdf
figures: manuscripts/figures.pdf

# manuscript/figures/frequentist_uncertainty-1.pdf
# pdftk $^ cat output $@
# manuscript/figures.Rmd 
manuscript/figures.pdf: manuscript/figures.Rmd \
manuscript/figures/pareto_demo-1.pdf \
manuscript/figures/predict_censor-1.pdf \
manuscript/figures/stan.pdf \
manuscript/figures/bayesian_model-1.pdf \
manuscript/figures/bayesian_area-1.pdf
	Rscript -e "rmarkdown::render('$<', output_format = 'pdf_document')"
	-pdftk manuscript/figures.pdf cat 2-end output manuscript/figures2.pdf
	-rm manuscript/figures.pdf
	-mv manuscript/figures2.pdf manuscript/figures.pdf

manuscript/figures/pareto_demo-1.pdf: scripts/00_simulation.R
	Rscript $<

manuscript/figures/predict_censor-1.pdf: scripts/01_censoring.R manuscript/figures/pareto_demo-1.pdf
	Rscript $<

manuscript/figures/frequentist_uncertainty-1.pdf: scripts/02_frequentist.R
	Rscript $<

manuscript/figures/stan.pdf: pareto_model.stan
	render50 -f -o $@ -P $< 
	pdfcrop $@ $@
	pdfcrop --margins '0 -30 -200 0' --clip $@ $@

manuscript/figures/bayesian_area-1.pdf: scripts/03_bayesian.R manuscript/figures/predict_censor-1.pdf
	Rscript $<

manuscript: manuscript/manuscript.pdf

manuscript/manuscript.pdf: manuscript/manuscript.tex manuscript/pareto-lakes.bib
	cd manuscript && pdflatex manuscript.tex
	cd manuscript && bibtex manuscript

manuscript/manuscript.bbl: manuscript/manuscript.tex manuscript/pareto-lakes.bib
	cd manuscript && pdflatex manuscript.tex
	cd manuscript && bibtex manuscript
	cd manuscript && pdflatex manuscript.tex

clean:
	-rm -rf manuscript/figures
	-mkdir manuscript/figures
	-mkdir -p manuscript/figures
	-rm arxiv_submission.zip
	-rm manuscript/manuscript.bbl
	-rm data/pareto_bayes.rds data/alphas.rds data/area_bayes.rds 
