# Makefile for common development tasks

.PHONY: venv install serve clean

venv:
	python3 -m venv .venv
	.venv/bin/python -m pip install --upgrade pip

install: venv
	.venv/bin/pip install -r requirements.txt

serve: install
	.venv/bin/mkdocs serve

clean:
	rm -rf .venv
	rm -rf site/
