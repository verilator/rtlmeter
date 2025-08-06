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

import os
from dataclasses import dataclass
from typing import Any, Dict, List, final

from rtlmeter import misc
from rtlmeter.context import CTX


# Get scalar attribute from the last descriptor that contains it, later overwrites earlier
def _gatherScalar(key: str, *descs: dict[str, Any]) -> str | None:
    result: str | None = None
    for desc in descs:
        if (value := desc.get(key)) is not None:
            result = str(value)
    return result


# Get list attribute from desciptors, concatenationg them in order
def _gatherList(key: str, *descs: dict[str, Any]) -> List[str]:
    result: List[str] = []
    for desc in descs:
        result.extend(str(_) for _ in desc.get(key, []))
    return result


# Get dict attribute from desciptors, overriding earlier entries with later entries
def _gatherDict(key: str, *descs: dict[str, Any]) -> Dict[str, str]:
    result: Dict[str, str] = {}
    for desc in descs:
        result.update((k, str(v)) for k, v in desc.get(key, {}).items())
    return result


@final
@dataclass(init=False)
class CompileDescriptor:
    case: str
    design: str
    config: str

    designDir: str

    prepHook: str | None
    postHook: str | None

    verilogSourceFiles: List[str]
    verilogIncludeFiles: List[str]
    verilogDefines: Dict[str, str]

    cppSourceFiles: List[str]
    cppIncludeFiles: List[str]
    cppDefines: Dict[str, str]

    topModule: str

    verilatorArgs: List[str]

    def __init__(self, case: str) -> None:
        self.design, self.config = case.split(":")
        self.case = case

        yamlDesc = CTX.descriptors[self.design]
        rootDesc = yamlDesc["compile"] or {}
        cfgDesc = yamlDesc["configurations"][self.config]["compile"] or {}

        gatherScalar = lambda _: _gatherScalar(_, rootDesc, cfgDesc)
        gatherList = lambda _: _gatherList(_, rootDesc, cfgDesc)
        gatherDict = lambda _: _gatherDict(_, rootDesc, cfgDesc)

        self.designDir = yamlDesc["designDir"]

        # prepHook is optional
        if (value := gatherScalar("prepHook")) is not None:
            self.prepHook = os.path.join(self.designDir, value)
        else:
            self.prepHook = None

        # postHook is optional
        if (value := gatherScalar("postHook")) is not None:
            self.postHook = os.path.join(self.designDir, value)
        else:
            self.postHook = None

        # verilogSourceFiles are optional
        self.verilogSourceFiles = [
            os.path.join(self.designDir, _) for _ in gatherList("verilogSourceFiles")
        ]
        self.verilogSourceFiles.append(os.path.join(CTX.rootDir, "rtl", "__rtlmeter_utils.sv"))
        # verilogIncludeFiles are optional
        self.verilogIncludeFiles = [
            os.path.join(self.designDir, _) for _ in gatherList("verilogIncludeFiles")
        ]
        self.verilogIncludeFiles.append(
            os.path.join(CTX.rootDir, "rtl", "__rtlmeter_top_include.vh")
        )
        # verilogDefines are optional
        self.verilogDefines = gatherDict("verilogDefines")

        # cppSourceFiles are optional
        self.cppSourceFiles = [
            os.path.join(self.designDir, _) for _ in gatherList("cppSourceFiles")
        ]
        # cppIncludeFiles are optional
        self.cppIncludeFiles = [
            os.path.join(self.designDir, _) for _ in gatherList("cppIncludeFiles")
        ]
        # cppDefines are optional
        self.cppDefines = gatherDict("cppDefines")

        # topModule is required
        if (value := gatherScalar("topModule")) is not None:
            self.topModule = value
        else:
            misc.fatal(f"{yamlDesc['__file__']} does not specify 'topModule'")

        # mainClock is required
        if (value := gatherScalar("mainClock")) is not None:
            self.verilogDefines["__RTLMETER_MAIN_CLOCK"] = value
        else:
            misc.fatal(f"{yamlDesc['__file__']} does not specify 'mainClock'")

        # verilatorArgs are optional
        self.verilatorArgs = gatherList("verilatorArgs")


@final
@dataclass(init=False)
class ExecuteDescriptor:
    case: str
    design: str
    config: str
    test: str

    designDir: str

    prepHook: str | None
    postHook: str | None

    args: List[str]
    files: List[str]
    tags: List[str]

    def __init__(self, case: str) -> None:
        self.design, self.config, self.test = case.split(":")
        self.case = f"{self.design}:{self.config}:{self.test}"

        yamlDesc = CTX.descriptors[self.design]
        rootCmnDesc = yamlDesc["execute"]["common"]
        rootTstDesc = yamlDesc["execute"]["tests"].get(self.test, {})
        cfgCmnDesc = yamlDesc["configurations"][self.config]["execute"]["common"]
        cfgTstDesc = yamlDesc["configurations"][self.config]["execute"]["tests"].get(self.test, {})

        gatherScalar = lambda _: _gatherScalar(_, rootCmnDesc, rootTstDesc, cfgCmnDesc, cfgTstDesc)
        gatherList = lambda _: _gatherList(_, rootCmnDesc, rootTstDesc, cfgCmnDesc, cfgTstDesc)

        self.designDir = yamlDesc["designDir"]

        # prepHook is optional
        if (value := gatherScalar("prepHook")) is not None:
            self.prepHook = os.path.join(self.designDir, value)
        else:
            self.prepHook = None

        # postHook is optional
        if (value := gatherScalar("postHook")) is not None:
            self.postHook = os.path.join(self.designDir, value)
        else:
            self.postHook = None

        # args are optional
        self.args = gatherList("args")

        # files are optional
        self.files = [os.path.join(self.designDir, _) for _ in gatherList("files")]

        # tags are optionsl
        self.tags = gatherList("tags")
