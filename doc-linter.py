#!/usr/bin/env python3

import re
import sys
import argparse
from functools import lru_cache
from dataclasses import dataclass
from pathlib import Path
from typing import Generator, Union

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


DOCS_DIR = "docs"
RE_TERM = re.compile(r"^:(?P<term_name>[^:]+):\s*(?P<term_value>\S+.*)\s*$")

class Linter:
	def __init__(self, start_path: Union[Path, str], auto_fix: bool, verbose: bool):
		if not isinstance(start_path, Path):
			start_path = Path(start_path)
		self._start_path = start_path
		self._auto_fix = auto_fix
		self._verbose = verbose
		self.errors: list[LintingError] = []

	def verbose(self, message: str):
		if self._verbose:
			print(message)

	@lru_cache(maxsize=0)
	def load_terms(self, terms_file: Path):
		self._terms = []
		for line in terms_file.read_text().splitlines():
			if match := RE_TERM.match(line):
				if match.group("term_value").startswith("{") and match.group("term_value").endswith("}"):
					# Reference to other term
					continue
				self._terms.append(Term(match.group("term_name"), match.group("term_value")))

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

	@lru_cache(maxsize=1000)
	def find_terms_file(self, start_path: Path) -> Path:
		terms_file = None
		while start_path.parent != start_path:
			terms_file = start_path.joinpath("modules/common/partials/opsi_terms.adoc")
			if terms_file.exists():
				return terms_file
			start_path = start_path.parent
		if not terms_file or not terms_file.exists():
			raise FileNotFoundError("Terms file not found")

	def check_terms(self, file: Path, content: str) -> tuple[list[LintingError, str]]:
		self.load_terms(self.find_terms_file(file.parent))

		errors = []
		for term in self._terms:
			for start_idx, end_idx, line_number, column_number in self.find_word(content, term.value):
				error = LintingError(file, line_number, column_number,f"Term {term.name!r} found")
				if self._auto_fix:
					content = f"{content[:start_idx]}{{{term.name}}}{content[end_idx:]}"
					error.fixed = True
				errors.append(error)
		return errors, content

	def check_caution_used(self, file: Path, content: str) -> tuple[list[LintingError, str]]:
		errors = []
		for word in "[CAUTION]", "CAUTION:":
			for start_idx, end_idx, line_number, column_number in self.find_word(content, word):
				replace = word.replace("CAUTION", "WARNING")
				error = LintingError(file, line_number, column_number,f"{word!r} used")
				if self._auto_fix:
					content = f"{content[:start_idx]}{replace}{content[end_idx:]}"
					error.fixed = True
				errors.append(error)
		return errors, content

	def run(self):
		if self._start_path.is_file():
			files = [self._start_path]
		else:
			files = list(self._start_path.rglob("*.asciidoc")) + list(self._start_path.rglob("*.adoc"))
		for file in files:
			self.verbose(f"Checking file: {file}")
			content = file.read_text(encoding="utf-8")
			orig_content = content
			errors, content = self.check_terms(file, content)
			self.errors.extend(errors)
			errors, content = self.check_caution_used(file, content)
			self.errors.extend(errors)
			if orig_content != content:
				file.write_text(content, encoding="utf-8")

def main():
	# Get option --fix with argparse
	parser = argparse.ArgumentParser()
	parser.add_argument("--auto-fix", action="store_true")
	parser.add_argument("--verbose", "-v", action="store_true")
	parser.add_argument("path", nargs="?")
	args = parser.parse_args()

	linter = Linter(args.path or DOCS_DIR, args.auto_fix, args.verbose)
	linter.run()
	for error in linter.errors:
		print(error)

	if [error for error in linter.errors if not error.fixed]:
		sys.exit(1)


if __name__ == "__main__":
	main()