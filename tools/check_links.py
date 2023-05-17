#! /usr/bin/env python3

# This module is part of the documentation for the
# desktop management solution opsi (open pc server integration)
# http://www.opsi.org

# Copyright (C) 2017 uib GmbH - http://www.uib.de/

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""
Check build documentation for broken links.
"""

import formatter
import os
import sys
from html.parser import HTMLParser
from urllib.request import urlopen
from urllib.error import HTTPError, URLError


class LinkCheckFailedError(Exception):
    pass


class LinksExtractor(HTMLParser):
    def __init__(self, formatter):
        super().__init__()
        self.links = set()

    def handle_starttag(self, tag, attrs):
        if tag != 'a':
            return

        for attr in attrs:
            tag, value = attr
            if tag != 'href':
                continue

            self.links.add(value)


def main():
    buildDir = os.path.join(os.path.dirname(__file__), '..', 'build')
    buildDir = os.path.abspath(buildDir)

    links = set()
    for fileIndex, htmlfile in enumerate(find_html_files(buildDir)):
        # print("Checking {0}".format(htmlfile))
        for link in sanitize_links(get_links_from_file(htmlfile)):
            # print("Found link: {0}".format(link))
            links.add(link)

    fails = 0
    for linkIndex, link in enumerate(sorted(links), start=1):
        try:
            check_link(link)
        except (HTTPError, LinkCheckFailedError, URLError) as error:
            fails += 1
            print("Connection to {} failed: {}".format(link, error))

    print("Checked {0} links.".format(linkIndex))
    if fails:
        # print("{} requests failed.".format(fails))
        raise LinkCheckFailedError("Could not open {} links!".format(fails))
    else:
        print("All links working.")


def find_html_files(path):
    for element in os.scandir(path):
        if element.is_symlink():
            continue

        if element.is_dir():
            yield from find_html_files(os.path.join(path, element.path))
        elif element.is_file():
            if element.name.endswith(('.html', '.htm')):
                yield os.path.join(path, element.path)


def get_links_from_file(filename):
    with open(filename) as inFile:
        content = inFile.read()

    htmlParser = LinksExtractor(formatter.NullFormatter())
    htmlParser.feed(content)
    for link in htmlParser.links:
        yield link


def sanitize_links(links):
    for link in links:
        skip = None
        if '<' in link and '>' in link:
            skip = "Skipping because special term in link: {!r}".format(link)
        elif link.startswith('#'):
            skip = "Skipping relative link: {!r}".format(link)
        elif link.startswith('mailto:'):
            skip = "Skipping mailto: link: {!r}".format(link)
        elif not link.startswith('http'):
            skip = "Skipping non-http link: {!r}".format(link)

        if skip:
            # print(skip)
            continue

        yield link


def check_link(link):
    with urlopen(link, timeout=30) as request:
        code = request.getcode()

        if code != 200:
            raise LinkCheckFailedError("Status code != 200")


if __name__ == '__main__':
    if sys.version_info < (3, 5):
        raise RuntimeError("Requiring at least Python 3.5")

    main()
