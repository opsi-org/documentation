#!/bin/sh

#
# create stylesheets from sass
# dependencies: ruby, ruby-gems
#
# gem install compass
# gem install zurb-foundation --version 4.3.2

NAME=opsi
STYLESHEETS=conf/stylesheets

echo $NAME
echo $STYLESHEETS

echo "### clone asciidoctor-stylesheet-factory ###"
git clone https://github.com/asciidoctor/asciidoctor-stylesheet-factory.git


echo "### copy files ###"
DESTINATION=asciidoctor-stylesheet-factory/sass
echo "### copy scss ###"
cp $STYLESHEETS/*.scss $DESTINATION
echo "### copy settings ###"
cp -r $STYLESHEETS/settings $DESTINATION
echo "### copy fonts"
cp -r $STYLESHEETS/fonts $DESTINATION


echo "### build css with compass ###"
cd asciidoctor-stylesheet-factory && compass compile sass/$NAME.scss && cd ..
pwd

echo "### copy stylesheets ###"
cp asciidoctor-stylesheet-factory/stylesheets/$NAME.css $STYLESHEETS

echo "### rm asciidoctor-stylesheet-factory ###"
rm -rf asciidoctor-stylesheet-factory