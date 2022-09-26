.PHONY: all

all: draft.pdf

draft.pdf: draft.md
	pandoc -s draft.md -o draft.tex --bibliography refs --natbib
	xelatex draft.tex
	bibtex draft
	xelatex draft.tex
	xelatex draft.tex
	-rm draft.log draft.aux draft.out draft.blg # draft.bbl draft.tex

response-to-reviewers.pdf: response-to-reviewers.md
	pandoc $< -H quote_setup.tex -V geometry:margin=1in -o $@