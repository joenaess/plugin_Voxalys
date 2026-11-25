.PHONY: lint format test ci install-plugin

lint:
	uv run ruff check . && uv run ruff format --check .

format:
	uv run ruff format . && uv run ruff check --fix .

test:
	uv run pytest

ci:
	$(MAKE) lint && $(MAKE) test

install-plugin:
	@if [ "$$(uname)" = "Darwin" ]; then \
		target="$$HOME/Library/Preferences/Praat Prefs/plugin_Voxalys"; \
	else \
		target="$$HOME/.praat-dir/plugin_Voxalys"; \
	fi; \
	mkdir -p "$$(dirname "$$target")"; \
	rm -rf "$$target"; \
	ln -s "$$(pwd)" "$$target"; \
	echo "Installed plugin symlink at $$target"
