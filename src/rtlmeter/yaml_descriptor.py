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

import functools
import importlib.resources
import os
from typing import Any, Dict

import jsonschema
import yaml

from rtlmeter import misc


# Load schema and compile validator
@functools.cache
def _validator():
    with (importlib.resources.files("rtlmeter") / "schema.yaml").open("r", encoding="utf-8") as f:
        textSchema = f.read()
        yamlSchema = yaml.safe_load(textSchema)
        yamlSchema = {key: val for key, val in yamlSchema.items() if not key.startswith("_")}
        return jsonschema.Draft202012Validator(yamlSchema)


# Add/normalize defaults
def _applyDefaults(desc: Dict[str, Any]) -> Dict[str, Any]:
    # YAML produces absent mapped values as 'None', we want them to be {}.
    desc["compile"] = desc.get("compile") or {}
    desc["execute"] = desc.get("execute") or {}
    desc["execute"]["common"] = desc["execute"].get("common") or {}
    desc["execute"]["tests"] = desc["execute"].get("tests") or {}
    desc["execute"]["tests"] = {k: v or {} for k, v in desc["execute"]["tests"].items()}
    return desc


# Load and validate a raw yaml descriptor. Return None if invalid
def load(fileName) -> Dict[str, Any] | None:
    if not os.path.exists(fileName):
        misc.fatal(f"Design descriptor does not exists: {fileName}")

    # Parse
    with open(fileName, "r", encoding="utf-8") as f:
        desc = yaml.safe_load(f)

    # Validate
    if errors := list(_validator().iter_errors(desc)):
        misc.error(f"Invalid design descriptor: {fileName}")
        for e in errors:
            message = "".join(e.schema.get("errorMessage", [e.message]))
            misc.echo(f"{e.json_path}: {message}")
        return None

    # Normalzie
    desc = _applyDefaults(desc)
    desc["configurations"] = {
        k: _applyDefaults(v or {}) for k, v in desc.get("configurations", {"default": {}}).items()
    }

    # Done
    return desc
