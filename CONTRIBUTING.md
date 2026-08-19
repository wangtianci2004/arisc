# Contributing to ARISC

Thank you for helping make autonomous research workflows more reliable and
reproducible. Contributions of code, documentation, tests, bug reports, and
workflow examples are welcome.

## Development setup

ARISC targets Bash 4.4+ on Linux, macOS, and WSL2. On macOS, install the development dependencies first with `brew install bash jq shellcheck tmux uv`. Then fork and clone the repository and run:

```bash
./install.sh --yes
make check
```

For a test-only setup that does not touch your real workspace, run:

```bash
make smoke
```

The smoke suite creates its own temporary home directory and fake upstream
skill repository. It removes them automatically when it exits.

## Pull requests

1. Keep changes focused and backward compatible where practical.
2. Add or update tests for behavior changes.
3. Update `README.md`, `help.md`, and `bin/arisc` together when commands change.
4. Run `make check` before opening a pull request.
5. Explain user-visible changes and migration concerns in the PR description.

Never commit API keys, `.env` files, generated research projects, reports, or
machine-specific `config` files. The root `.gitignore` excludes these by
default, but contributors remain responsible for reviewing staged changes.

## Commit style

Use short imperative subjects, for example `Add offline installer smoke test`.
Large changes should be split into reviewable commits when possible.

By participating, you agree to follow the project [Code of Conduct](CODE_OF_CONDUCT.md).
