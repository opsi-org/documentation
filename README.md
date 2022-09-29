# Documentation for opsi

This is the source of the official documentation for the open source client management solution [opsi](https://www.opsi.org/).

The documentation is published on the website [https://docs.opsi.org](https://docs.opsi.org/).

PDF and HTML manuals can be found [here](https://download.uib.de/opsi4.2/documentation/). 


## Edit this documentation

There are two main ways to edit the documentation:
1) Via the edit link on docs.opsi.org
2) Clone this repository and edit the files locally.


## How to build an opsi manual (Antora and HTML/PDF)

To build the docu files you can use the vscode devcontainer. 
In the devcontainer you can execute the different scripts to create the antora site and the  HTML/PDF manuals or you can use the vscode tasks. 

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


## Accept changes from external

Changes made via docs.opsi.org generate a merge request on gitlab.uib.de. 
Queries and discussions can take place via the GitLab interface on gitlab.uib.de. 
If the changes are to be adopted, gitlab.uib.de is first entered as the second remote in the local opsidoc repository: 

```
git remote add gitlab.uib.de git@gitlab.uib.de:pub/opsidoc.git
```

Then the merge to stable can be processed. Once everything has been merged, stable is pushed internally to gitlab.uib.gmbh.
The change is then automatically transferred to gitlab.uib.de and the merge request is automatically closed. 
