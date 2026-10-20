First, you might want to see the basic ways to [help and get help](help-fastapi-utils.md){.internal-link target=_blank}.

## Developing

Once you've cloned the repository, follow these instructions to set up your development environment.

### Prerequisites

You'll need:

- Python 3.8–3.12 (Python 3.12 is recommended for local development).
- [uv](https://docs.astral.sh/uv/), our Python package and environment manager.
- `make` for running development commands.

Install uv by following the [official installation instructions](https://docs.astral.sh/uv/getting-started/installation/).

### Set up the development environment

After cloning the repository, run:

```console
$ make develop
```

This uses `uv sync` to create a virtual environment in `.venv` and install the project, development dependencies, and optional integrations from `uv.lock`.

To explicitly use Python 3.12:

```console
$ uv sync --python 3.12 --extra all
```

uv can automatically download a compatible Python interpreter when needed.

### Running commands in the environment

You don't need to activate the virtual environment when using uv.

Simply prefix commands with `uv run`:

```console
$ uv run python
$ uv run pytest
$ uv run mypy
```

uv automatically uses the project's virtual environment.

If you prefer activating the environment manually:

```console
$ source .venv/bin/activate
```

On Windows, the activation command depends on your shell.

To verify the interpreter:

```console
$ uv run python -c "import sys; print(sys.executable)"
```

The resulting path should point to the project's `.venv` directory.

!!! tip
    Prefer `uv add` for managing dependencies rather than installing packages directly with `pip`.

    For example, to add a development dependency:

    ```console
    $ uv add --dev package-name
    ```

    This updates `pyproject.toml` and `uv.lock` together.

### Static code checks

The project uses:

- **Ruff** for linting and import organization.
- **Black** for code formatting.
- **mypy** for static type checking.
- **autoflake** for cleaning unused imports in documentation examples.

To automatically format the source code:

```console
$ make format
```

To check linting and formatting without modifying files:

```console
$ make lint
```

To run static type checking:

```console
$ make mypy
```

To run all static checks:

```console
$ make static
```

Note that `make static` also runs formatting and may modify source files.

!!! note
    The project currently contains some pre-existing lint and formatting issues. These are being addressed separately from the migration to uv.

To see all available Makefile commands:

```console
$ make
```

## Docs

The documentation uses [MkDocs](https://www.mkdocs.org/) with MkDocs Material.

Documentation is written in Markdown and stored in the `./docs` directory.

Many User Guide examples are actual Python source files located in `./docs/src/`. These files are included in the documentation during the build process.

### Documentation examples and tests

Many tests exercise the example source files used in the documentation.

This helps ensure that:

- Documentation examples stay up to date.
- Examples can be executed as written.
- Documented features receive test coverage.

### Build the documentation

To generate the documentation site:

```console
$ make docs-build
```

The generated website is available in `./site`.

### Live documentation preview

To start the MkDocs development server:

```console
$ make docs-live
```

Open [http://localhost:8008](http://localhost:8008) in your browser.

MkDocs automatically rebuilds the documentation when source files change.

### Format documentation examples

To format Python examples used in the documentation:

```console
$ make docs-format
```

## Tests

The project uses pytest.

Run all tests with coverage:

```console
$ make test
```

Alternatively, execute pytest directly:

```console
$ uv run pytest
```

### Coverage reports

To generate an HTML coverage report:

```console
$ make testcov
```

The report will be generated at:

```text
htmlcov/index.html
```

On macOS, the Makefile automatically opens the report in your browser.

On other platforms, open the HTML file manually.

### Pydantic compatibility

The project supports Pydantic v1 and v2.

To run the Pydantic v1 test workflow:

```console
$ make ci-v1
```

To restore the default Pydantic v2 environment and run its validation:

```console
$ make ci-v2
```

These workflows temporarily modify the development environment. Run `make develop` afterward if you need to restore the locked dependencies.

### Tests in your editor

Some tests require the documentation example modules to be importable.

Configure your editor to include `./docs/src` in `PYTHONPATH`.

For example, in VS Code, create an `.env` file containing:

```env
PYTHONPATH=./docs/src
```

Also configure your editor to use the project's Python interpreter:

```text
.venv/bin/python
```

On Windows, use `.venv\Scripts\python.exe`.

## Building the package

To build both the wheel and source distribution:

```console
$ make build
```

This uses `uv build` and writes the distributions to `./dist`.

## Dependency management

The project uses `pyproject.toml` for dependency declarations and `uv.lock` for reproducible development environments.

To update the lockfile:

```console
$ make lock
```

To reinstall dependencies according to the existing lockfile:

```console
$ make develop
```

Commit changes to `pyproject.toml` and `uv.lock` together.

## Version management

To bump the project version:

```console
$ make version version=patch
```

Supported version increments include `patch`, `minor`, and `major`.

The Makefile updates the version in `pyproject.toml` and `fastapi_utils/__init__.py`.

Version changes should be handled separately from unrelated development changes.