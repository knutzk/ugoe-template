SRC = talk

INKSCAPE = $(addsuffix .pdf, $(basename $(wildcard images/*.svg)))
TMP = tmp

.PHONY: all
.PHONY: clean
.PHONY: new
.PHONY: first-time
.PHONY: upload
.PHONY: compress
.PHONY: $(SRC).pdf

all: $(SRC).pdf

$(SRC).pdf: $(SRC).tex $(INKSCAPE)
	test -e $(TMP) || $(MAKE) first-time
	pdflatex -output-directory $(TMP)\
		-halt-on-error \
		-file-line-error \
		$(SRC).tex
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

#%.pdf: %.eps
#	epstopdf $(basename $@).eps
#
#%.eps: %.svg
#	inkscape --export-area-drawing --without-gui $(basename $@).svg --export-eps=$(basename $@).eps
%.pdf: %.svg
	inkscape --export-area-drawing --without-gui $(basename $@).svg --export-pdf=$(basename $@).pdf
#	#inkscape --export-area-page --without-gui $(basename $@).svg --export-pdf=$(basename $@).pdf

clean:
	-rm $(SRC).pdf
	-rm -r $(TMP)
	-rm images/*.pdf
	-rm images/*.eps
