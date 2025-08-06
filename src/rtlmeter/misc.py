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

import contextlib
import os
import sys
from typing import Any, Dict, Final, Generator, Literal, NoReturn

import termcolor

Format = Literal["ascii", "github"]

Style = Literal[
    "plain",
    "bold",
    "grey",
    "greyBold",
    "red",
    "redBold",
    "green",
    "greenBold",
    "yellow",
    "yellowBold",
    "blue",
    "blueBold",
    "magenta",
    "magentaBold",
    "cyan",
    "cyanBold",
]

# fmt: off
_STYLE_TO_TERMCOLOR: Final[Dict[Style, Dict[str, Any]]] = {
    "plain"       : { "color": None         , "attrs": []},
    "bold"        : { "color": None         , "attrs": ["bold"]},
    "grey"        : { "color": "grey"       , "attrs": []},
    "greyBold"    : { "color": "grey"       , "attrs": ["bold"]},
    "red"         : { "color": "red"        , "attrs": []},
    "redBold"     : { "color": "red"        , "attrs": ["bold"]},
    "green"       : { "color": "green"      , "attrs": []},
    "greenBold"   : { "color": "green"      , "attrs": ["bold"]},
    "yellow"      : { "color": "yellow"     , "attrs": []},
    "yellowBold"  : { "color": "yellow"     , "attrs": ["bold"]},
    "blue"        : { "color": "blue"       , "attrs": []},
    "blueBold"    : { "color": "blue"       , "attrs": ["bold"]},
    "magenta"     : { "color": "magenta"    , "attrs": []},
    "magentaBold" : { "color": "magenta"    , "attrs": ["bold"]},
    "cyan"        : { "color": "cyan"       , "attrs": []},
    "cyanBold"    : { "color": "cyan"       , "attrs": ["bold"]},
}
# fmt: on

_format: Format = "ascii"


def setFormat(format: Format) -> None:
    global _format  # pylint: disable=global-statement
    _format = format


def styled(text: str, style: Style = "plain") -> str:
    if _format == "ascii":
        return termcolor.colored(text, **_STYLE_TO_TERMCOLOR[style])
    if _format == "github":
        return text
    raise RuntimeError("unreachable")


def echo(message: str, style: Style = "plain") -> None:
    print(f"@@@ {styled(message, style=style)}")


def warning(message: str) -> None:
    echo(f"WARNING: {message}", style="yellow")


def error(message: str) -> None:
    echo(f"ERROR: {message}", style="red")


def fatal(message: str) -> NoReturn:
    echo(f"FATAL: {message}", style="redBold")
    sys.exit(1)


def styleByInterval(
    text: str,  # Text to style
    value: float,  # Discriminator value
    firstStyle: Style,
    *limitsAndStyles: float | Style,  # alternating (limit, Style) pairs
) -> str:
    prevLimit = float("-inf")
    it = iter((firstStyle,) + limitsAndStyles + (float("inf"),))
    for style, limit in zip(it, it):
        assert isinstance(style, str) and isinstance(limit, float), (
            "limitsAndStyles must be an alternating sequence of float limits and styles"
        )
        assert prevLimit < limit, "Limits must be ascending"
        if value < limit:
            return styled(text, style)
    raise ValueError(f"limit {value} is not well defined")


@contextlib.contextmanager
def inDirectory(dir: str) -> Generator:
    prevDir = os.getcwd()
    os.makedirs(dir, exist_ok=True)
    os.chdir(dir)
    try:
        yield
    finally:
        os.chdir(prevDir)
