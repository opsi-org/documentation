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
DBLATEX_OPTS := -p $(TOP_DIR)/conf/dblatex/asciidoc-dblatex.xsl \
		-s $(TOP_DIR)/conf/dblatex/asciidoc-dblatex.sty \

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

test: check

pdf: $(addsuffix .pdf,$(DOCS))
%.pdf: FORMAT = pdf

html: $(addsuffix .html,$(DOCS))
%.html: FORMAT = xhtml

epub: $(addsuffix .epub,$(DOCS))
%.epub: FORMAT = epub


%: FORMAT ?= $(subst html,xhtml,$(FORMATS))
%:
	@$(foreach L,$(LANG),\
		$(foreach F,$(FORMAT), \
			if [ -f $(TOP_DIR)/$(L)/$(basename $@)/$(basename $@).asciidoc ]; then	\
				mkdir -p $(DEST_DIR)/$(F)/$(L)/$(basename $@);					\
				if $(A2X) $(MAK_VERB) -D $(DEST_DIR)/$(F)/$(L)/$(basename $@) -f $(F)			\
					--asciidoc-opts='$(ASCIIDOC_OPTS) -a lang=$(L)'			\
					--dblatex-opts='$(DBLATEX_OPTS) -I $(TOP_DIR)/$(L)/images'\
					$(TOP_DIR)/$(L)/$(basename $@)/$(basename $@).asciidoc; then	\
					echo "INFO: Document $@ built successfully in flavor $(F) for language $(L)"; \
				else	\
					echo "ERROR: Document $@ could not be build for language $(L)";	\
				fi	\
				;	\
			else									\
				echo "ERROR: Document $@ does not exist for language $(L)";	\
			fi									\
			;									\
		)	\
	)

