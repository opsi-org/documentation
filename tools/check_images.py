#! /usr/bin/python

import os
import sys


def check_images(path):
	usedImages = set()

	for root, dirs, files in os.walk(path):
		for entry in files:
			if entry.endswith(".asciidoc"):
				filepath = os.path.join(root, entry)

				with open(filepath, "r") as f:
					for ln, line in enumerate(f, start=1):
						if line.startswith("image::"):
							inlinePath = line.split("::", 1)[1].rsplit("[")[0]
							if inlinePath.startswith("/"):
								imagepath = inlinePath
							else:
								imagepath = os.path.abspath(os.path.join(os.path.dirname(filepath), inlinePath))

							if not os.path.exists(imagepath):
								print "%s,%d: Image %s does not exist" % (entry, ln, imagepath)
							else:
								usedImages.add(imagepath)

	for root, dirs, files in os.walk(path):
		for entry in (os.path.join(root, x) for x in files):
			if entry.endswith(("png", "pdf", "jpg", "gif")):
				if os.path.abspath(entry) not in usedImages:
					print "Image %s is not used in any document" % (os.path.abspath(entry))


if __name__ == "__main__":
	if not len(sys.argv) > 1:
		print "Usage: python check_images.py [path]"
		sys.exit(1)

	check_images(os.path.abspath(sys.argv[1]))
