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
import os
import sys
import urllib
import urllib.error
import urllib.request
from collections import Counter, defaultdict
from typing import Dict, Set

from rtlmeter import misc
from rtlmeter.context import CTX
from rtlmeter.descriptors import CompileDescriptor, ExecuteDescriptor
from rtlmeter.subcommands.common import TAGS, ArgPatternMatcher, casesByTag


def checkFile(case: str, relFileName: str, absFileName: str, attrName: str) -> bool:
    if not os.path.exists(absFileName):
        misc.error(f"{case} - '{relFileName}' does not exist (from '{attrName}')")
        return True
    if not os.path.isfile(absFileName):
        misc.error(f"{case} - '{relFileName}' is not a regular file (from '{attrName}')")
        return True
    return False


def checkFileList(desc: CompileDescriptor | ExecuteDescriptor, attrName: str) -> bool:
    hasError = False
    seen: Dict[str, str] = {}
    for absFileName in getattr(desc, attrName):
        relFileName = os.path.relpath(absFileName, desc.designDir)
        hasError = checkFile(desc.case, relFileName, absFileName, attrName) or hasError
        baseName = os.path.basename(relFileName)
        if baseName in seen:
            hasError = True
            misc.error(f"{desc.case} - base name of files in '{attrName}' must be unique")
            misc.error(
                f"{' ' * len(desc.case)}   '{relFileName}' conflicts with '{seen[baseName]}'"
            )
        seen[baseName] = relFileName
    return hasError


def checkHook(desc: CompileDescriptor | ExecuteDescriptor, attrName: str) -> bool:
    if hook := getattr(desc, attrName):
        relFileName = os.path.relpath(hook, desc.designDir)
        if checkFile(desc.case, relFileName, hook, attrName):
            return True
        if not os.access(hook, os.X_OK):
            misc.error(f"{desc.case} - '{relFileName}' is not executable (from '{attrName}')")
            return True
    return False


def main(args: argparse.Namespace) -> None:
    hasError = False
    usedFiles: Dict[str, Set[str]] = defaultdict(set)

    doneDesign: Set[str] = set()
    doneCompileDescriptor: Set[str] = set()
    for case in args.cases:
        case, _ = case.rsplit(":", maxsplit=1)
        if case in doneCompileDescriptor:
            continue
        doneCompileDescriptor.add(case)

        cDescr = CompileDescriptor(case)
        # Check files
        hasError = checkFileList(cDescr, "verilogSourceFiles") or hasError
        hasError = checkFileList(cDescr, "verilogIncludeFiles") or hasError
        hasError = checkFileList(cDescr, "cppSourceFiles") or hasError
        hasError = checkFileList(cDescr, "cppIncludeFiles") or hasError
        usedFiles[cDescr.designDir].update(cDescr.verilogSourceFiles)
        usedFiles[cDescr.designDir].update(cDescr.verilogIncludeFiles)
        usedFiles[cDescr.designDir].update(cDescr.cppSourceFiles)
        usedFiles[cDescr.designDir].update(cDescr.cppIncludeFiles)
        # Check hooks
        hasError = checkHook(cDescr, "prepHook") or hasError
        if absFileName := cDescr.prepHook:
            usedFiles[cDescr.designDir].add(absFileName)
        hasError = checkHook(cDescr, "postHook") or hasError
        if absFileName := cDescr.postHook:
            usedFiles[cDescr.designDir].add(absFileName)

        design, _ = case.split(":")
        if design in doneDesign:
            continue
        doneDesign.add(design)

        yamlDescr = CTX.descriptors[design]
        for item in yamlDescr["origin"]:
            repo = item["repository"]
            licenses = item["licenses"]
            if repo != "local":
                try:
                    with urllib.request.urlopen(repo):
                        pass
                except urllib.error.URLError:
                    hasError = True
                    misc.error(f"{design} - Cannot open repository URL: {repo}")
            for license in licenses:
                fileName = os.path.join(yamlDescr["designDir"], license)
                usedFiles[cDescr.designDir].add(os.path.abspath(fileName))
                if not os.path.exists(fileName):
                    misc.error(f"{design} - License file does not exists: {fileName}")
                elif not os.path.isfile(fileName):
                    misc.error(f"{design} - License file does a file: {fileName}")

    for case in args.cases:
        eDescr = ExecuteDescriptor(case)
        # Check files
        hasError = checkFileList(eDescr, "files") or hasError
        usedFiles[eDescr.designDir].update(eDescr.files)
        # Check hooks
        hasError = checkHook(eDescr, "prepHook") or hasError
        if absFileName := eDescr.prepHook:
            usedFiles[eDescr.designDir].add(absFileName)
        hasError = checkHook(eDescr, "postHook") or hasError
        if absFileName := eDescr.postHook:
            usedFiles[eDescr.designDir].add(absFileName)
        for tag in eDescr.tags:
            if tag not in TAGS:
                hasError = True
                misc.error(f"{case} - '{tag}' is not a valid tag")

    # If checked all descriptors for a design, verify there are no stray files
    checkedDesigns = Counter(_.split(":")[0] for _ in args.cases)
    allDesigns = Counter(_.split(":")[0] for _ in CTX.availableCases)
    if all(allDesigns[k] == v for k, v in checkedDesigns.items()):
        for designDir in sorted(usedFiles):
            used = usedFiles[designDir]
            used.add(os.path.join(designDir, "descriptor.yaml"))
            for dirName, _, fileNames in os.walk(designDir):
                for fileName in fileNames:
                    absFileName = os.path.join(dirName, fileName)
                    if absFileName not in used:
                        hasError = True
                        relFileName = os.path.relpath(absFileName, CTX.rootDir)
                        misc.error(f"'{relFileName}' is not used by any case")

    if hasError:
        sys.exit(1)
    if len(args.cases) == len(CTX.availableCases):
        misc.echo("Everything seems to be in order", style="greenBold")


def addSubcommands(subParsers) -> None:
    # Subcommand "validate"
    parser: argparse.ArgumentParser = subParsers.add_parser(
        "validate",
        help="Validate case descriptors",
        allow_abbrev=False,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.set_defaults(entryPoint=main)
    parser.add_argument(
        "--cases",
        help="Cases to run",
        type=ArgPatternMatcher("cases", lambda: CTX.availableCases, casesByTag),
        metavar="CASES",
        default="*",
    )
