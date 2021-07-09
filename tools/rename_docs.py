#! /usr/bin/python

import os
import shutil
import sys


def rename_docs(path, documenttype, dest):

	print(documenttype)
	assert documenttype in ("pdf", "epub", "xhtml")

	if not dest.endswith(documenttype):
		dest = os.path.join(dest, documenttype)
		print(dest)
	try:
		os.makedirs(dest)
	except OSError:
		pass

	for root, dirs, files in os.walk(path):
		for entry in files:
			if entry.endswith(documenttype):
				d = root.split("/")
				lang = d[d.index(documenttype)+1]

				source = os.path.join(root, entry)
				destination = os.path.join(dest, "%s.%s" % ("%s-%s" % (entry.rsplit(".", 1)[0], lang), documenttype))

				print("Copying {0!r} to {1!r}".format(source, destination))
				shutil.copy2(source, destination)


if __name__ == "__main__":
	if not len(sys.argv) > 3:
		print "Usage: python rename_docs.py [path] [type] [dest]"
		sys.exit(1)

	try:
		rename_docs(os.path.abspath(sys.argv[1]), sys.argv[2], sys.argv[3])
	except Exception as e:
		print >> sys.stderr, e
		sys.exit(1)
