# Copyright 2025 RTLMeter contributors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
PYTHON := $(ROOT_DIR)/venv/bin/python
export PYTHONPATH := "$(ROOT_DIR)/src:$(PYTHONPATH)"

.DEFAULT_GOAL := help

.PHONY: venv
venv:
	# Create virtual environment using the host python3 from $$PATH
	python3 -m venv $(ROOT_DIR)/venv
	# Install python3 dependencies
	$(ROOT_DIR)/venv/bin/pip3 install -r python-requirements.txt || \
	$(ROOT_DIR)/venv/bin/pip3 install -r python-requirements.txt

.PHONY: typecheck
typecheck:
	env MYPYPATH=$(PYTHONPATH) $(PYTHON) -m mypy --disable-error-code=import-untyped src/rtlmeter/main.py

.PHONY: lint
lint:
	$(PYTHON) -m pylint src

.PHONY: spellcheck
spellcheck:
	$(MAKE) -C docs spelling

.PHONY: check
check: typecheck lint spellcheck

.PHONY: format
format:
	$(PYTHON) -m ruff check --select I --fix src
	$(PYTHON) -m ruff format src
	$(PYTHON) -m ruff format docs/source/conf.py

help:
	@echo "Available targets:"
	@echo "  venv:        Setup Pytnon virtual env under the venv directory"
	@echo "  check:       typecheck + lint + spellcheck"
	@echo "  typecheck:   Run Python type checker on src"
	@echo "  lint:        Run Python linter on src"
	@echo "  spellcheck:  Run spell checker on docs"
	@echo "  format:      Run Python formatter"
