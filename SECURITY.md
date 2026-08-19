# Security Policy

## Supported versions

Security fixes are applied to the latest release. Users should upgrade their
workspace checkout and run `arisc update` before reporting an issue.

## Reporting a vulnerability

Do not open a public issue for vulnerabilities that could expose credentials,
execute unintended commands, or cross project boundaries. Use GitHub's private
security-advisory flow for this repository. If that feature is unavailable,
contact the repository owner privately.

Include the affected version (`arisc --version`), operating system, a minimal
reproduction, expected impact, and any suggested mitigation. Remove secrets,
tokens, private repository URLs, research data, and `.env` contents from all
reports.

ARISC executes local tools and manages symlinks by design. Only configure
trusted research-skill repositories with `arisc repo setup`, and review changes
before running `arisc update`.
