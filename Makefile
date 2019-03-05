.PHONY: data figures tables manuscript all

all: data figures tables manuscript

data: data/iris.csv

data/iris.csv: scripts/00_get_iris.R
	Rscript $<

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

tables: data manuscript/tables.pdf

manuscript/tables.pdf: tables/01_iris_table.pdf
	pdftk $^ cat output manuscript/tables.pdf

tables/01_iris_table.pdf: tables/01_iris_table.Rmd
	Rscript -e "rmarkdown::render('$<', output_format = 'pdf_document')"

manuscript: manuscript/manuscript.pdf

manuscript/manuscript.pdf: manuscript/manuscript.Rmd manuscript/pinp.cls manuscript/appendix.pdf figures tables manuscript/pinp.bib
	Rscript -e "rmarkdown::render('$<')"
