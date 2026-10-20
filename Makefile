SHELL := /bin/bash
.DEFAULT_GOAL := help

pkg_src = fastapi_utils
tests_src = tests
docs_src = docs/src
all_src = $(pkg_src) $(tests_src)

UV := uv
UV_RUN := $(UV) run --extra all

mypy_base = $(UV_RUN) mypy --show-error-codes
mypy = $(mypy_base) $(all_src)
test = $(UV_RUN) pytest --cov=$(pkg_src)

.PHONY: all
all: static test

.PHONY: static
static: format lint mypy

.PHONY: test ## Run tests with coverage
test:
	$(test)

.PHONY: format ## Auto-format source code
format:
	$(UV_RUN) black $(all_src)
	$(UV_RUN) black -l 82 $(docs_src)
	$(UV_RUN) ruff check --fix $(all_src)

.PHONY: lint ## Run linting and formatting checks
lint:
	$(UV_RUN) ruff check $(all_src)
	$(UV_RUN) black --check --diff $(all_src)
	$(UV_RUN) black -l 82 $(docs_src) --check --diff

.PHONY: mypy ## Run static type checking
mypy:
	$(mypy)

.PHONY: testcov ## Generate HTML coverage report
testcov:
	$(test)
	@echo "Building HTML coverage report..."
	$(UV_RUN) coverage html
	@echo "Coverage report: htmlcov/index.html"
	@if [ "$$(uname -s)" = "Darwin" ]; then \
		open htmlcov/index.html; \
	fi

.PHONY: ci-v1 ## Run CI with Pydantic v1
ci-v1: install-v1
	$(MAKE) lint test UV_RUN="$(UV) run --no-sync"

.PHONY: ci-v2 ## Run CI with Pydantic v2
ci-v2: install-v2
	$(MAKE) lint mypy test

.PHONY: install-v1 ## Install Pydantic v1 test environment
install-v1:
	$(UV) sync --locked --extra all
	$(UV) pip uninstall --python .venv/bin/python \
		pydantic-settings typing-inspect
	$(UV) pip install --python .venv/bin/python \
		"pydantic>=1.10,<2.0"

.PHONY: install-v2 ## Restore Pydantic v2 environment
install-v2:
	$(UV) sync --locked --extra all \
		--reinstall-package pydantic

.PHONY: lock ## Update uv.lock
lock:
	$(UV) lock

.PHONY: develop ## Set up development environment
develop:
	$(UV) sync --locked --extra all

.PHONY: build ## Build wheel and source distribution
build:
	$(UV) build

.PHONY: check ## Run checks without changing source files
check: lint mypy test build

.PHONY: version ## Bump version (make version version=minor)
version:
	@test -n "$(version)" || \
		(echo "Usage: make version version=patch|minor|major" && exit 1)
	$(UV) version --bump $(version)
	$(eval NEW_VERS := $(shell grep '^version = ' pyproject.toml | head -1 | cut -d'"' -f2))
	@sed -i.bak \
		's/__version__ = .*/__version__ = "$(NEW_VERS)"/g' \
		$(pkg_src)/__init__.py
	@rm -f $(pkg_src)/__init__.py.bak
	@echo "Version updated to $(NEW_VERS)"

.PHONY: docs-build ## Build documentation
docs-build:
	cp README.md docs/index.md
	cp CONTRIBUTING.md docs/contributing.md
	cp CHANGELOG.md docs/release-notes.md
	$(UV_RUN) mkdocs build

.PHONY: docs-format ## Format documentation Python code
docs-format:
	$(UV_RUN) ruff check $(docs_src)
	$(UV_RUN) autoflake -r \
		--remove-all-unused-imports \
		--ignore-init-module-imports \
		$(docs_src) -i
	$(UV_RUN) black -l 82 $(docs_src)

.PHONY: docs-live ## Serve documentation with live reload
docs-live:
	$(UV_RUN) mkdocs serve --dev-addr 0.0.0.0:8008

.PHONY: clean ## Remove build and cache artifacts
clean:
	find . -type f \( -name '*.py[co]' -o -name '*~' \
		-o -name '.*~' -o -name '.coverage*' \) -delete
	find . -type d \( \
		-name '__pycache__' -o \
		-name '*.egg-info' -o \
		-name 'pip-wheel-metadata' -o \
		-name '.pytest_cache' -o \
		-name '.cache' -o \
		-name '.mypy_cache' -o \
		-name '.ruff_cache' -o \
		-name 'htmlcov' -o \
		-name 'build' -o \
		-name 'dist' \
	\) -prune -exec rm -rf {} +

.PHONY: help ## Display available commands
help:
	@grep -E '^.PHONY: .*## .*$$' $(MAKEFILE_LIST) | \
		sort | \
		awk 'BEGIN {FS = ".PHONY: |## "}; \
		{printf "\033[36m%-16s\033[0m %s\n", $$2, $$3}'
