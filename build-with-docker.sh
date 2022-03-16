#!/usr/bin/env bash

# User command
# docker run --rm -it -u $(id -u ${USER}):$(id -g ${USER}) -v ${pwd}:/opsidoc docker.uib.gmbh/fabian/opsidoc-antora:latest /opsidoc/build-with-docker.sh de manual

LANG=$1
DOC=$2

cd  /opsidoc
sudo apt update
sudo apt install -y curl git
curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
sudo apt update
sudo apt install -y nodejs
sudo apt install -y build-essential
pwd 
ls
git --version
sudo npm i
sudo npm install asciidoctor-interdoc-reftext
sudo gem install asciidoctor-interdoc-reftext
sudo gem install rouge
/opsidoc/tools/make-books.sh -l $LANG -m -n $DOC

