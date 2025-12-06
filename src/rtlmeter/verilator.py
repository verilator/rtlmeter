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

import itertools
import json
import os
import re
import subprocess
from typing import Final, List, Tuple

from rtlmeter import metrics
from rtlmeter.cgraph import CGraph, CNode
from rtlmeter.context import CTX
from rtlmeter.descriptors import CompileDescriptor, ExecuteDescriptor
from rtlmeter.runcmd import runcmd

_PREFIX: Final[str] = "Vsim"

flatten = itertools.chain.from_iterable


def _verilate(
    cgraph: CGraph, descr: CompileDescriptor, compileDir: str, extraArgs: List[str]
) -> CNode:
    step = "verilate"

    def job() -> bool:
        cmd = [
            "verilator",
            "--cc",
            "--main",
            "--exe",
            "--timing",
            "--quiet-stats",
            "-Wno-fatal",
            "--prefix",
            _PREFIX,
        ]
        # Top module
        cmd.extend(["--top-module", descr.topModule])
        # Verilog incdirs
        if descr.verilogIncludeFiles:
            cmd.append("+incdir+verilogIncludeFiles")
        # Verilog defines
        cmd.extend(f"+define+{k}={v}" for k, v in sorted(descr.verilogDefines.items()))
        # CPP incdirs
        if descr.cppIncludeFiles:
            cmd.extend(("-CFLAGS", "-I../cppIncludeFiles"))
        # CPP defines
        cmd.extend(flatten(("-CFLAGS", f"-D{k}={v}") for k, v in sorted(descr.cppDefines.items())))
        # File list (via -f to save space on the command line)
        fileList = "filelist"
        with open(fileList, "w", encoding="utf-8") as fd:
            for fileName in descr.verilogSourceFiles:
                fd.write(f"verilogSourceFiles/{os.path.basename(fileName)}\n")
            for fileName in descr.cppSourceFiles:
                fd.write(f"cppSourceFiles/{os.path.basename(fileName)}\n")
        cmd.extend(["-f", fileList])
        # Extra options from descriptor
        cmd.extend(descr.verilatorArgs)
        # Extra optoins from command line
        cmd.extend(extraArgs)
        # Add extra defines if --trace is used. We check this here in case it came from extraArgs.
        lastTraceOption = (
            [None] + [_ for _ in cmd if _ in ("--trace", "--trace-vcd", "--trace-fst")]
        ).pop()
        if lastTraceOption in ("--trace", "--trace-vcd"):
            cmd.append("+define+__RTLMETER_TRACE_VCD")
        elif lastTraceOption == "--trace-fst":
            cmd.append("+define+__RTLMETER_TRACE_FST")
        # Run it
        if runcmd(cmd, step):
            # On successfull run, gather some metrics
            with open(f"_{step}/time.json", "r", encoding="utf-8") as fd:
                tData = json.load(fd)
            data = {descr.case: {step: tData}}
            with open(f"_{step}/metrics.json", "w", encoding="utf-8") as fd:
                json.dump(data, fd)
            return True
        # Command failed
        return False

    return cgraph.addNode(f"{descr.case} - Verilate", compileDir, step, job)


def _cppbuild(cgraph: CGraph, descr: CompileDescriptor, compileDir: str) -> CNode:
    step = "cppbuild"

    def job() -> bool:
        cmd = [
            "make",
            "-j",
            str(CTX.nProc),
            "-C",
            "obj_dir",
            "-f",
            f"{_PREFIX}.mk",
            "VM_PARALLEL_BUILDS=1",
        ]
        env = {"CCACHE_DEBUG": "1", "CCACHE_DEBUGLEVEL": "1"}
        # Run it
        if runcmd(cmd, step, env):
            # On successfull run, gather some metrics
            with open(f"_{step}/time.json", "r", encoding="utf-8") as fd:
                cData = json.load(fd)
            # Gather ccache hit rate and code size
            codesectionRe = re.compile(r"^\s*\d+\s+\S+\s+(\S+)\s+.*\bCODE\b.*")
            ccacheHits: int = 0
            objectFiles: int = 0
            codeSize: int = 0
            for dirPath, _, fileNames in os.walk("obj_dir"):
                for fileName in fileNames:
                    if fileName.endswith("ccache-log") and ".o." in fileName:
                        with open(os.path.join(dirPath, fileName), "r", encoding="utf-8") as fd:
                            if "Succeeded getting cached result" in fd.read():
                                ccacheHits += 1
                    elif fileName.endswith("Slow.o"):
                        objectFiles += 1
                        continue
                    elif fileName.endswith(".o"):
                        objectFiles += 1
                        with subprocess.Popen(
                            args=["objdump", "-w", "-h", os.path.join(dirPath, fileName)],
                            stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT,
                            text=True,
                            encoding="utf-8",
                        ) as process:
                            assert process.stdout, "stdout is None"
                            for line in process.stdout:
                                if codesectionMatch := codesectionRe.match(line):
                                    codeSize += int(codesectionMatch.group(1), base=16)
            cData["ccacheHit"] = 100.0 * ccacheHits / max(objectFiles, 1)
            cData["codeSize"] = codeSize * 1e-6
            # Result data
            data = {descr.case: {step: cData}}
            # Add combined 'verilate' + 'cppbuild'
            with open("_verilate/time.json", "r", encoding="utf-8") as fd:
                tData = json.load(fd)
            for k, v in cData.items():
                mDef = metrics.metricDef(k)
                if (accumulate := mDef.accumulate) is not None:
                    tData[k] = accumulate(tData.get(k, mDef.identityValue), v)
            data[descr.case]["compile"] = tData
            with open(f"_{step}/metrics.json", "w", encoding="utf-8") as fd:
                json.dump(data, fd)
            return True
        # Command failed
        return False

    return cgraph.addNode(f"{descr.case} - Build C++", compileDir, step, job)


def compile(
    cgraph: CGraph, descr: CompileDescriptor, compileDir: str, extraArgs: List[str]
) -> Tuple[CNode, CNode]:
    verilateNode = _verilate(cgraph, descr, compileDir, extraArgs)
    cppbuildNode = _cppbuild(cgraph, descr, compileDir)
    cgraph.addEdge(verilateNode, cppbuildNode)
    return verilateNode, cppbuildNode


def execute(
    cgraph: CGraph, descr: ExecuteDescriptor, compileDir: str, executeDir: str, extraArgs: List[str]
) -> Tuple[CNode, CNode]:
    step = "execute"

    def job() -> bool:
        cmd = [os.path.join(compileDir, "obj_dir", _PREFIX), "+verilator+quiet"]
        cmd.extend(descr.args)
        cmd.extend(extraArgs)
        # Run it
        if runcmd(cmd, step):
            # On successfull run, gather some metrics
            with open(f"_{step}/time.json", "r", encoding="utf-8") as fd:
                tData = json.load(fd)
            # Add design cycles
            with open("_rtlmeter_cycles.txt", "r", encoding="utf-8") as fd:
                clocks = int(fd.read())
                tData["clocks"] = clocks
                kiloCycles = clocks / 1e3
                tData["speed"] = kiloCycles / tData["elapsed"]
            # Gather trace file size if present:
            for tracePath in ("trace.vcd", "trace.fst"):
                if not os.path.exists(tracePath):
                    continue
                traceSize = 0
                if os.path.isdir(tracePath):
                    for dirName, _, fileNames in os.walk(tracePath):
                        for fileName in fileNames:
                            traceSize += os.path.getsize(os.path.join(dirName, fileName))
                else:
                    traceSize = os.path.getsize(tracePath)
                tData["traceSize"] = traceSize / (2**20)
            # Write it out
            data = {descr.case: {step: tData}}
            with open(f"_{step}/metrics.json", "w", encoding="utf-8") as fd:
                json.dump(data, fd)
            return True
        # Command failed
        return False

    node = cgraph.addNode(f"{descr.case} - Execute simulation", executeDir, step, job)
    return node, node
