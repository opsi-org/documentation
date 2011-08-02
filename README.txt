Dependencies
============

Building the opsi manuals requires the following software to be installed on your system:

* asciidoc >= 8.6.3
* dblatex  >= 0.3

How to build an opsi manual
==========================

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

. Using debug and verbose mode (debug mode includes verbose, but leaves temporary build files in /tmp for inspection)


----
VERBOSE=True make
DEBUG=True make
----
