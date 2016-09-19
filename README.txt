# Documentation for opsi

This is the official documentation for the open source client management solution [opsi](http://www.opsi.org/en).

## Dependencies

Building the opsi manuals requires the following software to be installed on your system:

* asciidoc >= 8.6.3
* dblatex  >= 0.3

### Additional packages on Ubuntu

Since Ubuntu 13.04 you need the following additional packages:
* texlive-lang-german
* texlive-lang-english
* texlive-lang-french
* lmodern

See also:
http://tex.stackexchange.com/questions/139700/package-babel-error-unknown-option-francais

## How to build an opsi manual

. Build all documents in all available languages and formats

----
make
----

. Build all documents in all available languages in a specific format, eg. pdf

----
make pdf
----

. Build a specific document in all available languages and formats

----
make opsi-getting-started
----

. Build a specific document in all available languages in a specific format, eg. pdf

----
make opsi-getting-started.pdf
----

. Build a specific document in a specific languages in a specific format, eg. pdf

----
make LANG=de opsi-getting-started.pdf
----

. Check spelling of all documents

----
make spell
----

. Clean up the build tree

----
make clean
----

. Validate image paths and usage

----
make check
----

. copies an rename the files at build to pub (eg. build\pdf\de\opsi-getting-started\opsi-getting-started.pdf to pub\pdf\opsi-getting-started-de.pdf )

----
make rename
----

. Using debug and verbose mode (debug mode includes verbose, but leaves temporary build files in /tmp for inspection)

----
VERBOSE=True make
DEBUG=True make
----
