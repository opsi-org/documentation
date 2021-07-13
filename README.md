# Documentation for opsi

This is the source of the official documentation for the open source client management solution [opsi](http://www.opsi.org/).

A rendered version is available [here](https://download.uib.de/opsi4.1/documentation/).


## Dependencies

Building the opsi manuals requires the following software to be installed on your system:

- asciidoctor: https://github.com/asciidoctor/asciidoctor
- asciidoctor-pdf: https://github.com/asciidoctor/asciidoctor-pdf
  - graphicsmagick
  - prawn-gmagick: better PNG support
- asciidoctor-epub3: https://github.com/asciidoctor/asciidoctor-epub3

To build the documentation using make you will need:

* make


## How to build an opsi manual

### Build all documents in all available languages and formats

``` shell
make
```

### Build all documents in all available languages in a specific format

Just give the format you want to build, e.g. `pdf`.

``` shell
make pdf
```

### Build a specific document in all available languages and formats

``` shell
make opsi-getting-started
```

### Build a specific document in all available languages in a specific format

Give the name of the document with the specific extension.

``` shell
make opsi-getting-started.pdf
```

### Build a specific document in a specific languages in a specific format

Set the `LANG` parameter to the wanted value.
Possible values are `de`, `en` and `fr`.

``` shell
make LANG=de opsi-getting-started.pdf
```

### Build Slides

``` shell
make -f tools/slide.mk LANG=de slide-test.html
```
needed packages:
apt install source-highlight
apt install python-pygment

### Check spelling of all documents

``` shell
make spell
```

### Clean up the build tree

``` shell
make clean
```

### Validate image paths and usage

Checks for unused images.

``` shell
make check
```

### Prepare for publication

Prepares the publication of documents with a folder-structure similar to
the one found at `download.uib.de`.
This will copy and rename the files at `build` so they appear in `pub`.
As an example it will copy `build\pdf\de\opsi-getting-started\opsi-getting-started.pdf` to the pub directory and rename it resulting in `pub\opsi-getting-started-de.pdf`.
Additionally it will create `pub.tar`.
This tarball includes the structure like the `pub` folder.
It can be copied to the desired machine and then extracted there.

``` shell
make publish
```

### Debugging

For verbose output set the enviroment variable `VERBOSE` to `True`.

``` shell
VERBOSE=True make
```

Debug mode includes verbose but leaves temporary build files in `/tmp` for inspection.

``` shell
VERBOSE=True make
DEBUG=True make
```

### Checking for valid links

With `tools/check_links.py` exists a script that scans build documentation for broken links.
This script requires Python 3 to be able to run.

To use this script first build the documentation and then run the script. It will show what links are broken and in case there are links that can not be opened a non-zero exit-code will be returned.


## How to build an opsi manual with tools/create_docs.py


### Dependencies

- asciidoctor: https://github.com/asciidoctor/asciidoctor
- asciidoctor-pdf: https://github.com/asciidoctor/asciidoctor-pdf
  - graphicsmagick
  - prawn-gmagick: better PNG support
- asciidoctor-epub3: https://github.com/asciidoctor/asciidoctor-epub3


### CSS stylesheet

To create the css files call the build_stylesheets.sh script.

dependencies:
- ruby, ruby-gems
- gem install compass
- gem install zurb-foundation
<!-- - gem install zurb-foundation  --version 4.3.2 -->

```shell
sh tools/build_stylesheets.sh
```
This will take the *conf/stylesheets/opsi.sass* and build the *conf/stylesheets/opsi.css*. Images used in the scss files should be in the folder *conf/stylesheets/images*. `create_docu.py` copies all images to *\<destination\>/opsi-css/* (location of the html file).

### PDF theme

To modify the PDF theme edit conf/opsi-theme.yml.

### Docu

The docu can be build with the script `create_docu.py` in tools. This script uses python 3.

```shell
usage: create_docu.py [-h] [-l LANG] [-o OUTPUTS] [-f FILES] [-t THEME]
                      [-s STYLESHEET] [-p PROJECT_PATH]

optional arguments:
  -h, --help            show this help message and exit
  -l LANG, --lang LANG  languages to build (en,de)
  -o OUTPUTS, --outputs OUTPUTS
                        output formates (html,pdf)
  -f FILES, --files FILES
                        docu files to build
  -t THEME, --theme THEME
                        pdf theme to use (opsi)
  -s STYLESHEET, --stylesheet STYLESHEET
                        html style to use (opsi)
  -p PROJECT_PATH, --project-path PROJECT_PATH
                        path to docu project
```

Examples:

Build all files in all languages as html and pdf with opsi style/theme:
```shell
python3 tools/create_docu.py -s opsi -t opsi
```

Build opsi manual in english and german as html:
```shell
python3 tools/create_docu.py -l en,de -o html -s opsi -f opsi-manual-v4.2
```

Build getting started pdf in english:
```shell
python3 tools/create_docu.py -l en -o pdf -t opsi -f opsi-getting-started-v4.2
```