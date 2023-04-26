#!/usr/bin/env python3

import re
import sys
import argparse
from dataclasses import dataclass
from pathlib import Path
from typing import Generator

@dataclass
class Term():
	name: str
	value: str

@dataclass(repr=False)
class LintingError:
	file: Path
	line: int
	column: int
	message: str
	fixed: bool = False

	def __repr__(self) -> str:
		fixed = " (fixed)" if self.fixed else ""
		return f"{self.file}:{self.line}:{self.column}: {self.message}{fixed}"


DOCS_DIR = Path("docs")
RE_TERM = re.compile(r"^:(?P<term_name>[^:]+):\s*(?P<term_value>\S+.*)\s*$")

class Linter:
	def __init__(self, doc_path: Path, auto_fix: bool):
		self.doc_path = doc_path
		self.auto_fix = auto_fix
		self.terms: list[Term] = []
		self.errors: list[LintingError] = []

	def run(self):
		for language in DOCS_DIR.iterdir():
			if language.is_dir():
				self.check_docs(language)

	def load_terms(self, terms_file: Path):
		self.terms = []
		for line in terms_file.read_text().splitlines():
			if match := RE_TERM.match(line):
				self.terms.append(Term(match.group("term_name"), match.group("term_value")))

	def find_word(self, content: str, word: str) -> Generator[tuple[int, int, int, int], None, None]:
		search_idx = 0
		while True:
			start_idx = content.find(word, search_idx)
			if start_idx < 0:
				break

			end_idx = start_idx + len(word)
			search_idx = end_idx
			if content[start_idx-1] not in (" ", "\t", "\n") or content[start_idx + len(word)] not in (" ", "\t", "\n"):
				# Part of a word
				continue
			line_start = content.rfind("\n", 0, start_idx)
			line_number = content.count("\n", 0, start_idx) + 1
			column_number = start_idx - line_start
			yield start_idx, end_idx, line_number, column_number

	def check_terms(self, file: Path, content: str) -> tuple[list[LintingError, str]]:
		errors = []
		for term in self.terms:
			for start_idx, end_idx, line_number, column_number in self.find_word(content, term.value):
				error = LintingError(file, line_number, column_number,f"Term {term.name!r} found")
				if self.auto_fix:
					content = f"{content[:start_idx]}{{{term.name}}}{content[end_idx:]}"
					error.fixed = True
				errors.append(error)
		return errors, content

	def check_caution_used(self, file: Path, content: str) -> tuple[list[LintingError, str]]:
		errors = []
		for start_idx, end_idx, line_number, column_number in self.find_word(content, ":CAUTION"):
			error = LintingError(file, line_number, column_number,f":CAUTION used")
			if self.auto_fix:
				content = f"{content[:start_idx]}:WARNING{content[end_idx:]}"
				error.fixed = True
			errors.append(error)
		return errors, content

	def check_docs(self, doc_path: Path):
		self.load_terms(doc_path / "modules/common/partials/opsi_terms.adoc")
		# Iterate over all files ending with .asiicoc
		for file in doc_path.glob("**/*.asciidoc"):
			content = file.read_text(encoding="utf-8")
			orig_content = content
			errors, content = self.check_terms(file, content)
			errors, content = self.check_caution_used(file, content)
			self.errors.extend(errors)
			if orig_content != content:
				file.write_text(content, encoding="utf-8")

def main():
	# Get option --fix with argparse
	parser = argparse.ArgumentParser()
	parser.add_argument("--auto-fix", action="store_true")
	args = parser.parse_args()

	linter = Linter(DOCS_DIR, args.auto_fix)
	linter.run()
	for error in linter.errors:
		print(error)

	if [error for error in linter.errors if not error.fixed]:
		sys.exit(1)


if __name__ == "__main__":
	main()