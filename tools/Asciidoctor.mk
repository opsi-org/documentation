INSTALL := /usr/bin/install
INSTALL_DATA := ${INSTALL} -m 644

SYS_DOC_DIR := /usr/share/doc/opsi

PYTHON := /usr/bin/python3
PYTHON2 := /usr/bin/python2

FIND := /usr/bin/find

TOP_DIR := $(shell dirname $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))
DEST_DIR := $(TOP_DIR)/build
PUB_DIR := $(TOP_DIR)/pub

LOG_LEVEL=30


ifdef VERBOSE
LOG_LEVEL=20
endif

ifdef DEBUG
VERBOSE := true
DBLATEX_OPTS := $(DBLATEX_OPTS) --debug
LOG_LEVEL=10
endif


REFERENCE_LANG := de

LANG := de en
DOCS ?= $(shell find $(TOP_DIR)/$(REFERENCE_LANG) -type d -name "opsi*" -exec basename {} \;)

FORMATS := html pdf epub

.PHONY: clean disclean check spell test install build all $(FORMATS)

all: $(FORMATS)

clean:
	-rm -rf $(DEST_DIR)
	-rm -rf $(PUB_DIR)
	-find $(TOP_DIR) -type f -name "*~" -exec rm {} \;

distclean: clean


build: all

install: build
	$(INSTALL) -d $(DESTDIR)/$(SYS_DOC_DIR);
	cp -r $(DEST_DIR)/* $(DESTDIR)/$(SYS_DOC_DIR)/

check: clean
	$(foreach L,$(LANG), \
		$(PYTHON2) tools/check_images.py $(TOP_DIR)/$(L); \
	)

rename:
	$(foreach F,$(FORMAT), \
		$(PYTHON2) tools/rename_docs.py $(DEST_DIR) $(F) $(PUB_DIR);	\
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
	cp -r $(DEST_DIR)/html/de/* $(PUB_DIR)/html/
	mkdir -p $(PUB_DIR)/html/en/
	cp -r $(DEST_DIR)/html/en/* $(PUB_DIR)/html/en/
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

%: FORMAT ?= $(FORMATS) #$(subst html,xhtml,$(FORMATS))
%:
	@$(foreach L,$(LANG),\
		$(foreach F,$(FORMAT), \
			if [ -f $(TOP_DIR)/$(L)/$(basename $@)/$(basename $@).asciidoc ]; then	\
				if $(PYTHON) tools/create_docu.py --log-level $(LOG_LEVEL) -l $(L) -o $(F) -s opsi  -t opsi -f $(basename $@); then	\
					echo "INFO: Document $@ built successfully in flavor $(F) for language $(L)"; \
				else	\
					echo "ERROR: Document $@ could not be built for language $(L)";	\
				fi	\
				;	\
			else									\
				echo "ERROR: Document $@ does not exist for language $(L)";	\
				echo $(TOP_DIR)/$(L)/$(basename $@)/$(basename $@).asciidoc; \
			fi									\
			;									\
		)	\
	)
