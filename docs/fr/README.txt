Comment contribuer
==================

Les manuels sont au format asciidoc, donc éditables avec un simple éditeur de texte.

Installer en local le dépôt svn du projet avec la commande (dans un repertoire créé à l'avance):

svn co https://svn.opsi.org/opsidoc .

Aller dans le repertoire trunk de la langue sur laquelle on désire travailler (traduire ou relire et corriger) et faire ses propres modifications dans les fichiers asciidoc.

Envoyer le/s fichier/s à l'adresse mail opsi@opensides.be, avec, si possible, quelques explications sur les changements (nouvelle traduction, correction de fautes, ect.).

Ne pas oublier de mettre à jour votre copie locale régulièrement avec :

svn update

pour plus de renseignements sur l'usage de svn voir :

http://dev.nozav.org/indexfr.html



Compilation des manuels d'OPSI
==============================

Dépendances
============

La compilation des manuels OPSI requiert l'installation des logiciels suivants sur votre système:

* asciidoc >= 8.6.3
* dblatex  >= 0.3

Comment construire un manuel OPSI
=================================

. Créer tous les documents dans toutes les langues et les formats disponibles

----
make
----

. Créer tous les documents dans toutes les langues dans un format spécifique, par exemple pdf

----
make pdf
----

. Créer un document spécifique dans toutes les langues et les formats disponibles

----
make opsi-getting-started
----

. Créer un document spécifique dans toutes les langues dans un format spécifique, par exemple pdf

----
make opsi-getting-started.pdf
----

. Créer un document spécifique dans une langue spécifique et un format spécifique, par exemple pdf

----
make LANG=de opsi-getting-started.pdf
----

. Vérifier l'orthographe de tous les documents

----
make spell
----

. Nettoyer l'arborescence de construction

----
make clean
----

. Valider les chemins des images et leur utilisation

----
make check
----

. Utiliser le débogage et le mode verbeux (mode debug inclut verbose, mais laisse la construction des fichiers temporaires dans /tmp for inspection)


----
VERBOSE=True make
DEBUG=True make
----
