#!/usr/bin/env bash

# User command
# docker run --rm -it -u $(id -u ${USER}):$(id -g ${USER}) -v ${pwd}:/opsidoc docker.uib.gmbh/opsi/opsidoc-antora:latest /opsidoc/build-with-docker.sh de manual

LANG=$1
DOC=$2

cd  /opsidoc
/opsidoc/tools/make-books.sh -l $LANG -m -n $DOC
