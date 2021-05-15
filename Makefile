.PHONY: data figures manuscript all

all: data figures manuscript

figures: data manuscript/figures.pdf manuscript/appendix.pdf

manuscript/figures.pdf: manuscript/figures.Rmd figures/01_iris-1.pdf
	Rscript -e "rmarkdown::render('$<', output_format = 'pdf_document')"
	-pdftk manuscript/figures.pdf cat 2-end output manuscript/figures2.pdf
	-mv manuscript/figures2.pdf manuscript/figures.pdf

figures/01_iris-1.pdf: figures/01_iris.Rmd
	Rscript -e "rmarkdown::render('$<', output_format = 'pdf_document')"

manuscript/appendix.pdf: manuscript/appendix.Rmd figures/A1_iris-1.pdf
	Rscript -e "rmarkdown::render('$<', output_format = 'pdf_document')"
	-pdftk manuscript/appendix.pdf cat 2-end output manuscript/appendix2.pdf
	-mv manuscript/appendix2.pdf manuscript/appendix.pdf

figures/A1_iris-1.pdf: figures/A1_iris.Rmd
	Rscript -e "rmarkdown::render('$<', output_format = 'pdf_document')"

manuscript: manuscript/manuscript.pdf

manuscript/manuscript.pdf: manuscript/template.tex manuscript/pinp.cls manuscript/appendix.pdf figures manuscript/pinp.bib
	cd manuscript && pdflatex template.tex
