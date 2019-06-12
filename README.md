# Documentation for opsi

This is the official documentation for the open source client management solution [opsi](http://www.opsi.org/).

## Dependencies

Building the opsi manuals requires the following software to be installed on your system:

* asciidoc >= 8.6.3
* dblatex  >= 0.3
* aspell

### Additional packages on Ubuntu

Since Ubuntu 13.04 you need the following additional packages:
* texlive-lang-german
* texlive-lang-english
* texlive-lang-french
* lmodern

See also:
http://tex.stackexchange.com/questions/139700/package-babel-error-unknown-option-francais

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
