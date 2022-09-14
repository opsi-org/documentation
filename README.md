# Documentation for opsi

This is the source of the official documentation for the open source client management solution [opsi](http://www.opsi.org/).

The documentation is published on the website [http://docs.opsi.org](http://docs.opsi.org/).

PDF and HTML manuals can be found [here](https://download.uib.de/opsi4.1/documentation/). 


## Edit this documentation






## How to build an opsi manual Antora and HTML/PDF

To build the docu files you can use the vscode devconatiner. 
In the devcontainer you can execute the diffrent scripts to create the antora site and the  HTML/PDF manuals or you can use the vscode tasks. 

<!-- You can use the `build-with-docker.sh` script or the vscode Devcontainer to create the opsi docs.  

 ### build-with-docker.sh

Call the following comannd to build the pdf and html manual in german.
```
docker run --rm -it
-u $(id -u ${USER}):$(id -g ${USER})
-v ${pwd}:/opsidoc
docker.uib.gmbh/fabian/opsidoc-antora:latest
/opsidoc/build-with-docker.sh de manual
```
Possible  manuals to build:

- manual 
- getting-started
- releasenotes
- windows-client-manual
- linux-client-manual
- macos-client-manual
- opsi-script-manual
- quickinstall
- opsi-script-reference-card
- supportmatrix -->


<!-- ### Dependencies

- asciidoctor: https://github.com/asciidoctor/asciidoctor
- asciidoctor-pdf: https://github.com/asciidoctor/asciidoctor-pdf
  - graphicsmagick
  - prawn-gmagick: better PNG support
- asciidoctor-epub3: https://github.com/asciidoctor/asciidoctor-epub3 -->


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

### Create Antora site

To create the antore site with your local changes excute: 

```shell
npx antora --log-level=debug local-playbook.yml
```

### Create PDF/HTML docu

The docu the can be build with the script `make-books.sh` in tools. This script uses python 3.

```shell
./tools/make-books.sh -l <LANGUAGE> -m -n <DOCUMENT>
```

```shell
HELP

Usage: ./bin/makepdf [-c] [-d] [-h] [-l] [-m] [-n <manual|getting-started|releasenotes|windows-client-manual|linux-client-manual|macos-client-manual|opsi-script-manual|quickinstall|opsi-script-reference-card|supportmatrix>]

-h ... help
-l ... set language default is de
-e ... Set failure level to ERROR (default: FATAL)
-c ... clean the build/ directory (contains the pdf)
-d ... Debug mode, prints the book to be converted. Only in combination with -m and/or -n
-m ... Build all available manuals
-n ... Build manual <name>. Only in combination with -m
```

Examples:

```
./tools/make-books.sh -l en -m -n manual
```

### Checking for valid links

With `tools/check_links.py` exists a script that scans build documentation for broken links.
This script requires Python 3 to be able to run.

To use this script first build the documentation and then run the script. It will show what links are broken and in case there are links that can not be opened a non-zero exit-code will be returned.
