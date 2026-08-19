.PHONY: check syntax platform smoke audit

check: syntax platform smoke

syntax:
	@bash -n install.sh bin/* tests/*.sh

smoke:
	@bash tests/smoke.sh

platform:
	@bash tests/platform.sh

audit:
	@WORKSPACE_ROOT="$(CURDIR)" bin/arisc audit
