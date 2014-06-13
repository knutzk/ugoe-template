SRC = an-example

INKSCAPE = $(addsuffix .pdf, $(basename $(wildcard images/*.svg)))
DIA_FILES = $(addsuffix .pdf, $(basename $(wildcard images/*.dia)))
GNUPLOT_FILES = $(addsuffix .tex, $(basename $(wildcard gnuplot/*.plot)))
ROOT_FILES = $(addsuffix .pdf, $(basename $(wildcard root/*.C)))
TMP = tmp

.PHONY: all
.PHONY: clean
.PHONY: new
.PHONY: first-time
.PHONY: upload
.PHONY: compress
.PHONY: $(SRC).pdf

all: $(SRC).pdf

$(SRC).pdf: $(SRC).tex $(INKSCAPE) $(GNUPLOT_FILES) $(ROOT_FILES)
	#*/*.tex
	test -e $(TMP) || make first-time
#	test -e $(TMP)/$(SRC).lin || echo '\item' > $(TMP)/$(SRC).lin
#	-rm tmp/commit-header.autotex
#	sh generate-commit-header.sh > tmp/commit-header.autotex
	pdflatex -output-directory $(TMP)\
		-halt-on-error \
		-file-line-error \
		$(SRC).tex
#	sh generate-lecture-index.sh $(TMP)/$(SRC).log > $(TMP)/$(SRC).lin
	-makeindex $(TMP)/$(SRC)
	-bibtex $(TMP)/$(SRC)
	cp $(TMP)/$(SRC).pdf .

compress:
	gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile="$(SRC).pdf" "$(TMP)/$(SRC).pdf"

first-time:
	mkdir $(TMP)
	mkdir $(TMP)/gnuplot
	make $(SRC).pdf
	rm $(SRC).pdf

new: clean all

all-evince: all
	evince $(SRC).pdf > /dev/null 2>&1&

%.pdf: %.eps
	epstopdf $(basename $@).eps

%.eps: %.svg
	inkscape --export-area-drawing --without-gui $(basename $@).svg --export-eps=$(basename $@).eps
#%.pdf: %.svg
#	#inkscape --export-area-page --without-gui $(basename $@).svg --export-pdf=$(basename $@).pdf
#	inkscape --export-area-drawing --without-gui $(basename $@).svg --export-pdf=$(basename $@).pdf

%.pdf: %.dia
	dia -e $(basename $@).eps -t eps $(basename $@).dia

%.tex: %.plot
	test -e $(TMP)/gnuplot || mkdir -p $(TMP)/gnuplot
	gnuplot $(basename $@).plot

%.svg: %.C
	root -n -b -l -q '$(basename $@).C("$@")'

clean:
	-rm $(SRC).pdf
	-rm -r $(TMP)
	-rm images/*.pdf
	-rm images/*.eps
	-rm root/*.svg
	-rm root/*.pdf

upload: all
	scp $(SRC).pdf ja@0x53a.de:htdocs-deaggi/files/eboc.pdf
