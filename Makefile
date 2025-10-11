# Makefile for common development tasks

.PHONY: venv install serve serve-dev clean

venv:
	python3 -m venv .venv
	.venv/bin/python -m pip install --upgrade pip

install: venv
	.venv/bin/pip install -r requirements.txt

serve: install
	.venv/bin/mkdocs serve

# Development server with live reload and CSS watch
serve-dev:
	.venv/bin/mkdocs serve --watch-theme --watch docs/stylesheets --watch docs/assets

clean:
	rm -rf .venv
	rm -rf site/
