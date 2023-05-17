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

FORMATS := html pdf

.PHONY: clean disclean check spell test install

clean:
	-rm -rf $(DEST_DIR)
	-rm -rf $(PUB_DIR)
	-find $(TOP_DIR) -type f -name "*~" -exec rm {} \;

distclean: clean

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
	mkdir -p $(PUB_DIR)/html/
	cp -r $(DEST_DIR)/html/de/* $(PUB_DIR)/html/
	mkdir -p $(PUB_DIR)/html/en/
	cp -r $(DEST_DIR)/html/en/* $(PUB_DIR)/html/en/
	cd $(PUB_DIR) ; \
	tar -cvf pub.tar ./*
	mv $(PUB_DIR)/pub.tar $(TOP_DIR)

test: check
