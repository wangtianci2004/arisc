# Changelog

All notable changes to ARISC are documented in this file. The project follows
[Semantic Versioning](https://semver.org/) and the structure recommended by
[Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added

- Public open-source project metadata and MIT license.
- Non-interactive `arisc repo setup` for reproducible device provisioning.
- One-command installer mode with optional automatic uv installation.
- CI syntax, audit, and isolated project-creation smoke tests.
- Native GNU/Linux and BSD/macOS compatibility helpers.
- Ubuntu and macOS GitHub Actions matrix coverage.
- Root-level Agent installation prompt for unattended ARISC setup.
- Root-level Agent uninstall prompt with explicit research-data protection.
- Official ARIS skills repository as the root `aris-codex-skills` Git submodule.

### Changed

- Standardized the public product spelling as `ARISC`.
- macOS entrypoints automatically switch from the system Bash to Homebrew Bash 4.4+.
- Simplified the public CLI to the single `arisc` entrypoint.
- Standardized the default workspace directory as `~/arisc`.
- `arisc update` now updates the bundled submodule before reconciling project skills.

## [0.1.0] - 2026-08-19

### Added

- ARISC multi-project research workspace CLI.
- Isolated project creation, migration, lifecycle, monitoring, reporting,
  environment management, and base-workspace orchestration.
