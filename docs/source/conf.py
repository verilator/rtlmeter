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

# Configuration file for the Sphinx documentation builder.
# See https://www.sphinx-doc.org/en/master/usage/configuration.html

import subprocess

# -- Project information -----------------------------------------------------

project = "RTLMeter"
copyright = "2025, RTLMeter contributors"
author = "Geza Lore"

gitDescribe = subprocess.run(
    ["git", "describe", "--always", "--dirty=-dirty"], stdout=subprocess.PIPE, encoding="utf-8"
).stdout.strip()
version = gitDescribe
release = gitDescribe

# -- General configuration ---------------------------------------------------

needs_sphinx = "8.1"

extensions = ["sphinx_copybutton"]

exclude_patterns = []

# -- Options for nitpicky mode -----------------------------------------------

nitpicky = True

# -- Options for HTML output -------------------------------------------------

html_show_sphinx = False
html_domain_indices = False
html_use_index = False
html_copy_source = False
html_show_sourcelink = False


html_theme = "sphinx_rtd_theme"

html_theme_options = {}

html_context = {
    "display_github": True,
    "github_user": "verilator",
    "github_repo": "rtlmeter",
    "github_version": "main/docs/source/",
}

# -- Options for spelling ----------------------------------------------------

spelling_rowd_list_fileame = ["spelling_wordlist.txt"]
