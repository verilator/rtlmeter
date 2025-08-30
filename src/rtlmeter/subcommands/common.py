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

import argparse
import difflib
import fnmatch
import os
from functools import cached_property
from typing import Callable, Dict, Final, Iterable, List, Set, final

from rtlmeter.context import CTX
from rtlmeter.descriptors import ExecuteDescriptor

# fmt: off
TAGS: Final[Dict[str, str]] = {
    "sanity"    : "Very short cases suitable for quick functional sanity checking",
    "standard"  : "Standard set of cases suitable for baseline performance evaluation",
    "large"     : "Large cases that compile for a fairly long time ",
    "long"      : "Cases that execute for a fairly long time",
    "flaky"     : "Cases that might fail intermittently"
}
# fmt: on


def casesByTag() -> Dict[str, List[str]]:
    result: Dict[str, List[str]] = {}
    for case in CTX.availableCases:
        for tag in ExecuteDescriptor(case).tags:
            result.setdefault(tag, []).append(case)
    return result


# Expand and validate argument patterns
@final
class ArgPatternMatcher:
    what: str
    choicesLazy: Callable[[], Iterable[str]]
    tagsLazy: Callable[[], Dict[str, List[str]]]

    def __init__(
        self,
        what: str,
        choicesLazy: Callable[[], Iterable[str]],
        tagsLazy: Callable[[], Dict[str, List[str]]] = lambda: {},
    ) -> None:
        self.what = what
        self.choicesLazy = choicesLazy
        self.tagsLazy = tagsLazy

    @cached_property
    def _choices(self) -> List[str]:
        result = list(self.choicesLazy())
        assert len(result) == len(set(result)), "should be distinct"
        return result

    @cached_property
    def _tags(self) -> Dict[str, List[str]]:
        return self.tagsLazy()

    def _expand(self, item: str) -> List[str]:
        if item.startswith("!"):
            # Expand to excluded patters
            return ["!" + _ for _ in self._expand(item[1:])]
        if item.startswith("+"):
            # Get tagged cases
            if (expanded := self._tags.get(item[1:])) is not None:
                return expanded
            raise argparse.ArgumentTypeError(f"'{item}', is not a valid tag")
        if item.startswith("@"):
            # Read one pattern per line
            if not os.path.exists(item[1:]):
                raise argparse.ArgumentTypeError(f"'{item}' file does not exist")
            with open(item[1:], "r", encoding="utf-8") as f:
                return [_ for line in f for _ in self._expand(line.strip())]
        return [item]

    def __call__(self, spec: str) -> List[str]:
        patterns = [pattern for item in spec.split() for pattern in self._expand(item)]
        if not patterns:
            raise argparse.ArgumentTypeError(f"{self.what} specifier is empty")
        if all(_.startswith("!") for _ in patterns):
            patterns.insert(0, "*")
        result: List[str] = []
        included: Set[str] = set()
        for pattern in patterns:
            if matches := fnmatch.filter(self._choices, pattern.removeprefix("!")):
                if pattern.startswith("!"):
                    result = [_ for _ in result if _ not in matches]
                    included.difference_update(matches)
                else:
                    result.extend(_ for _ in matches if _ not in included)
                    included.update(matches)
                assert len(result) == len(included), "'result' should be distinct"
            else:
                msg = f"'{pattern}' does not name any valid {self.what}"
                if "*" not in pattern:
                    if suggestions := difflib.get_close_matches(pattern, self._choices, cutoff=0.8):
                        raise argparse.ArgumentTypeError(f"{msg}, did you mean '{suggestions[0]}'?")
                raise argparse.ArgumentTypeError(
                    f"{msg}, for valid choicese see 'rtlmeter show --{self.what}'"
                )
        assert set(result) == included, "'result' and 'incldued' does not match"
        return result


@final
class ArgRangedInt:
    minVal: int | None
    maxVal: int | None

    def __init__(self, minVal: int | None, maxVal: int | None) -> None:
        self.minVal = minVal
        self.maxVal = maxVal

    def __call__(self, val: str) -> int:
        try:
            value = int(val)
        except Exception as e:
            raise argparse.ArgumentTypeError("must be an integer") from e
        if self.minVal is not None and value < self.minVal:
            raise argparse.ArgumentTypeError(f"value must be at least {self.minVal}")
        if self.maxVal is not None and value > self.maxVal:
            raise argparse.ArgumentTypeError(f"value must be at most {self.maxVal}")
        return value


@final
class ArgExistingFileOrDirectory:
    def __call__(self, val: str) -> str:
        if not os.path.exists(val):
            raise argparse.ArgumentTypeError(f"'{val}' does not exist")
        if not os.path.isfile(val) and not os.path.isdir(val):
            raise argparse.ArgumentTypeError(f"'{val}' is not a regular file, nor a directory")
        return os.path.abspath(val)
