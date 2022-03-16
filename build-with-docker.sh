#!/usr/bin/env bash

# User command
# docker run --rm -it -u $(id -u ${USER}):$(id -g ${USER}) -v $(pwd):/opsidoc docker.uib.gmbh/opsi/opsidoc-asciidoctor:latest /opsidoc/build-with-docker.sh de pdf opsi-manual-v4.2

LANG=$1
FORMAT=$2
DOC=$3

cd /opsidoc
python3 ./tools/create_docu.py -l=$LANG -o=$FORMAT -f=$DOC
