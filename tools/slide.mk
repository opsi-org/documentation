INSTALL := /usr/bin/install
INSTALL_DATA := ${INSTALL} -m 644

SYS_DOC_DIR := /usr/share/doc/opsi

ASCIIDOC := /usr/bin/asciidoc
A2X := /usr/bin/a2x
PYTHON := /usr/bin/python

FIND := /usr/bin/find
ASPELL := /usr/bin/aspell

TOP_DIR := $(shell dirname $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))
DEST_DIR := $(TOP_DIR)/build
PUB_DIR := $(TOP_DIR)/pub

ASCIIDOC_OPTS := -f $(TOP_DIR)/conf/asciidoc.conf -a encoding=UTF-8
DBLATEX_OPTS := -p $(TOP_DIR)/conf/dblatex/asciidoc-dblatex-opsi-slide.xsl \
		-s $(TOP_DIR)/conf/dblatex/asciidoc-dblatex-opsi-slide.sty \

ifdef DEBUG
VERBOSE := true
DBLATEX_OPTS := $(DBLATEX_OPTS) --debug
endif

ifdef VERBOSE
MAK_VERB := -v
endif



REFERENCE_LANG := de

LANG := de en fr nl
DOCS ?= $(shell find $(TOP_DIR)/$(REFERENCE_LANG) -type d -name "opsi*" -exec basename {} \;)

FORMATS := html pdf epub

.PHONY: clean disclean check spell test install build all $(FORMATS)

all: $(FORMATS)

clean:
	-rm -rf $(DEST_DIR)
	-rm -rf $(PUB_DIR)
	-find $(TOP_DIR) -type f -name "*~" -exec rm {} \;

distclean: clean

spell:
	$(foreach L,$(LANG), \
		$(foreach D,$(DOCS), \
			if [ -f $(TOP_DIR)/$(L)/$(D)/$(D).asciidoc ]; then	\
				$(ASPELL) check -p $(TOP_DIR)/$(L)/opsi.dict -l $(L) --encoding=utf-8 $(TOP_DIR)/$(L)/$(D)/$(D).asciidoc;	\
			fi \
			;\
		)	\
	)
	$(ASPELL) check -p $(TOP_DIR)/en/opsi.dict -l en --encoding utf-8 $(TOP_DIR)/README.txt

build: all

install: build
	$(INSTALL) -d $(DESTDIR)/$(SYS_DOC_DIR);
	cp -r $(DEST_DIR)/* $(DESTDIR)/$(SYS_DOC_DIR)/

check: clean
	$(foreach L,$(LANG), \
		$(PYTHON) tools/check_images.py $(TOP_DIR)/$(L); \
	)

rename:
	$(foreach F,$(FORMAT), \
		$(PYTHON) tools/rename_docs.py $(DEST_DIR) $(F) $(PUB_DIR);	\
	)

publish: rename
	cp $(PUB_DIR)/pdf/* $(PUB_DIR); \
	rm -rf $(PUB_DIR)/pdf/
	mkdir -p $(PUB_DIR)/epub/en/
	mkdir -p $(PUB_DIR)/epub/de/
	cp $(PUB_DIR)/epub/*-en.epub $(PUB_DIR)/epub/en/
	cp $(PUB_DIR)/epub/*-de.epub $(PUB_DIR)/epub/de/
	rm $(PUB_DIR)/epub/*.epub
	mkdir -p $(PUB_DIR)/html/
	cp -r $(DEST_DIR)/xhtml/de/* $(PUB_DIR)/html/
	mkdir -p $(PUB_DIR)/html/en/
	cp -r $(DEST_DIR)/xhtml/en/* $(PUB_DIR)/html/en/
	rm -rf $(PUB_DIR)/xhtml
	cd $(PUB_DIR) ; \
	tar -cvf pub.tar ./*
	mv $(PUB_DIR)/pub.tar $(TOP_DIR)

test: check

pdf: $(addsuffix .pdf,$(DOCS))
%.pdf: FORMAT = pdf

html: $(addsuffix .html,$(DOCS))
%.html: FORMAT = html

epub: $(addsuffix .epub,$(DOCS))
%.epub: FORMAT = epub

%:
	set -x
	@$(foreach L,$(LANG),\
		$(foreach F,$(FORMAT), \
			echo "INFO: Document $@ : $(TOP_DIR)/$(L)/$(basename $@)/$(basename $@).asciidoc"; \
			if [ -f $(TOP_DIR)/$(L)/$(basename $@)/$(basename $@).asciidoc ]; then	\
				echo "create dest"; \
				mkdir -p $(DEST_DIR)/slide/$(L)/$(basename $@);	\
				if [ "$(F)" = "html" ];  then	\
					echo "start build html";	\
					if asciidoc -v $(ASCIIDOC_OPTS) --backend=$(TOP_DIR)/conf/deckjs \
						--out-file=$(DEST_DIR)/slide/$(L)/$(basename $@)/$(basename $@).$(F)						\
						$(TOP_DIR)/$(L)/$(basename $@)/$(basename $@).asciidoc; then	\
						echo "INFO: Document $@ built successfully in flavor $(F) for language $(L)"; \
					else	\
						echo "ERROR: Document $@ could not be built for language $(L)";	\
					fi	\
					;	\
				fi \
				;	\
				if [ "$(F)" = "pdf" ];  then	\
					echo "start build pdf";	\
					if [ -f $(TOP_DIR)/conf/docbook-xsl/slide-$(F).xsl ]; then	\
						XSLT_FILE="--xsl-file=$(TOP_DIR)/conf/docbook-xsl/slide-$(F).xsl" ;\
					else	\
						XSLT_FILE="--xsl-file=$(TOP_DIR)/conf/docbook-xsl/common.xsl"	;\
					fi;	\
					if $(A2X) $(MAK_VERB) -D $(DEST_DIR)/slide/$(L)/$(basename $@) -f $(F)			\
					--resource '$(TOP_DIR)/$(L)/images'	\
					--asciidoc-opts='$(ASCIIDOC_OPTS) -a lang=$(L) '			\
					--dblatex-opts='$(DBLATEX_OPTS) -I $(TOP_DIR)/$(L)/images'	\
					"$$XSLT_FILE"							\
					$(TOP_DIR)/$(L)/$(basename $@)/$(basename $@).asciidoc; then	\
						echo "INFO: Document $@ built successfully in flavor $(F) for language $(L)"; \
					else	\
						echo "ERROR: Document $@ could not be built for language $(L)";	\
					fi	\
					;	\
				fi \
				;	\
			else									\
				echo "ERROR: Document $@ does not exist for language $(L)";	\
			fi									\
			;									\
		)	\
	)

