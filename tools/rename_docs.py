#!/usr/bin/python

import os, sys, shutil

def rename_docs(path, t, dest):

	assert t in ("pdf","epub")

	if not dest.endswith(t):
		dest = os.path.join(dest,t)
	if not os.path.exists(dest):
		os.makedirs(dest)

	for root, dirs, files in os.walk(path):
		for entry in files:
			if entry.endswith(t):
				d = root.split("/")
				lang = d[d.index(t)+1]
				shutil.copy(os.path.join(root, entry), os.path.join(dest, "%s.%s" %( "%s-%s"%(entry.rsplit(".",1)[0],lang),t)))

if __name__=="__main__":
	if not len(sys.argv) > 3:
		print "Usage: python rename_docs.py [path] [type] [dest]"
		sys.exit(1)
	try:
		rename_docs(os.path.abspath(sys.argv[1]), sys.argv[2], sys.argv[3])
		sys.exit(0)
	except Exception, e:
		print >> sys.stderr, e
		sys.exit(1)
