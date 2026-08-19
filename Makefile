.PHONY: check syntax platform features smoke audit

check: syntax platform features smoke

syntax:
	@bash -n install.sh uninstall.sh bin/* lib/*.sh tests/*.sh

smoke:
	@bash tests/smoke.sh

platform:
	@bash tests/platform.sh

features:
	@bash tests/cli_features.sh

audit:
	@WORKSPACE_ROOT="$(CURDIR)" bin/arisc audit
