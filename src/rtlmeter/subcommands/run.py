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
import shlex
import shutil
import sys
from collections import defaultdict
from typing import Dict, List, Tuple

import tabulate

import rtlmeter.verilator as sim
from rtlmeter import misc
from rtlmeter.cgraph import CGraph, CNode, CStatus
from rtlmeter.context import CTX
from rtlmeter.descriptors import CompileDescriptor, ExecuteDescriptor
from rtlmeter.runcmd import runcmd
from rtlmeter.subcommands.common import ArgPatternMatcher, ArgRangedInt, casesByTag


# Add 'prep' and 'post' hooks if present
def addHooks(
    cgraph: CGraph,
    descr: CompileDescriptor | ExecuteDescriptor,
    dir: str,
    startNode: CNode,
    endNode: CNode,
) -> Tuple[CNode, CNode]:
    # If prep hook is given, run it before everything else
    if descr.prepHook is not None:
        hook = descr.prepHook
        step = "prepHook"
        node = cgraph.addNode(f"{descr.case} - Prep hook", dir, step, lambda: runcmd([hook], step))
        cgraph.addEdge(node, startNode)
        startNode = node
    # If post hook is given, run it after everything else
    if descr.postHook is not None:
        hook = descr.postHook
        step = "postHook"
        node = cgraph.addNode(f"{descr.case} - Post hook", dir, step, lambda: runcmd([hook], step))
        cgraph.addEdge(endNode, node)
        endNode = node
    # Done
    return startNode, endNode


def compile(
    cgraph: CGraph, descr: CompileDescriptor, compileDir: str, extraArgs: List[str]
) -> Tuple[CNode, CNode]:
    # Compilation
    startNode, endNode = sim.compile(cgraph, descr, compileDir, extraArgs)
    # Add prep and post hooks
    startNode, endNode = addHooks(cgraph, descr, compileDir, startNode, endNode)

    # Before anything else, link resource files for compilation
    def linkFiles() -> bool:
        for name in (
            "verilogSourceFiles",
            "verilogIncludeFiles",
            "cppSourceFiles",
            "cppIncludeFiles",
        ):
            shutil.rmtree(name, ignore_errors=True)
            if files := getattr(descr, name):
                os.makedirs(name)
                with misc.inDirectory(name):
                    for f in files:
                        os.symlink(os.path.relpath(f), os.path.basename(f))
        return True

    linkNode = cgraph.addNode(
        f"{descr.case} - Prepare files for compilation", compileDir, "files", linkFiles
    )
    cgraph.addEdge(linkNode, startNode)
    startNode = linkNode

    # Done
    return startNode, endNode


def execute(
    cgraph: CGraph, descr: ExecuteDescriptor, compileDir: str, executeDir: str, extraArgs: List[str]
) -> Tuple[CNode, CNode]:
    # Execution
    startNode, endNode = sim.execute(cgraph, descr, compileDir, executeDir, extraArgs)
    # Add prep and post hooks
    startNode, endNode = addHooks(cgraph, descr, executeDir, startNode, endNode)

    # Before anything else, link resource files for execution
    def linkFiles() -> bool:
        with misc.inDirectory(executeDir):
            for f in descr.files:
                dst = os.path.basename(f)
                if os.path.exists(dst):
                    os.remove(dst)
                os.symlink(os.path.relpath(f), dst)
            return True

    if descr.files:
        linkNode = cgraph.addNode(
            f"{descr.case} - Prepare files for execution", executeDir, "files", linkFiles
        )
        cgraph.addEdge(linkNode, startNode)
        startNode = linkNode

    # Done
    return startNode, endNode


def main(args: argparse.Namespace) -> None:
    CTX.verbose = args.verbose
    CTX.setTimeout(args.timeout)

    if CTX.verbose and args.compileArgs:
        misc.echo(f"compileArgs: {args.compileArgs}")

    compileRoot = args.compileRoot or args.workRoot
    executeRoot = args.executeRoot or args.workRoot

    cgraph: CGraph = CGraph()

    # Set up compilation jobs
    compileCNodes: Dict[str, List[CNode]] = defaultdict(list)
    for n in range(args.nCompile):
        for case in args.cases:
            case, _ = case.rsplit(":", maxsplit=1)

            if len(compileCNodes[case]) != n:
                continue
            assert len(compileCNodes[case]) == n

            cDescr = CompileDescriptor(case)
            compileDir = os.path.join(compileRoot, cDescr.design, cDescr.config, f"compile-{n}")

            _, endNode = compile(cgraph, cDescr, compileDir, args.compileArgs)
            compileCNodes[case].append(endNode)

    # Set up execution jobs
    for n in range(args.nExecute):
        for case in args.cases:
            # Always use the first compile node
            compileNode = compileCNodes[case.rsplit(":", maxsplit=1)[0]][0]

            eDescr: ExecuteDescriptor = ExecuteDescriptor(case)
            compileDir = os.path.join(compileRoot, eDescr.design, eDescr.config, "compile-0")
            executeDir = os.path.join(
                executeRoot, eDescr.design, eDescr.config, f"execute-{n}", eDescr.test
            )

            startNode, _ = execute(cgraph, eDescr, compileDir, executeDir, args.executeArgs)
            cgraph.addEdge(compileNode, startNode)

    # Run the graph
    nodeStatus = cgraph.runAll(args.retry)

    # Report failures if any
    table = []
    for node, status in nodeStatus.items():
        if status == CStatus.FAILURE_NOW:
            table.append([node.description, misc.styled("Failed on this run", style="redBold")])
        elif status == CStatus.FAILURE_BEFORE:
            table.append([node.description, misc.styled("Failed on earlier run", style="red")])
        elif status == CStatus.FAILED_DEPENDENCY:
            table.append(
                [node.description, misc.styled("Skipped due to failed dependency", style="yellow")]
            )
    if table:
        misc.echo("Some steps have failed", style="redBold")
        print(tabulate.tabulate(table, headers=["Step", "Status"], tablefmt="plain"))
        sys.exit(1)
    misc.echo("All cases passed", style="greenBold")


def addSubcommands(subParsers) -> None:
    # Subcommand "run"
    parser: argparse.ArgumentParser = subParsers.add_parser(
        "run",
        help="Run some cases",
        description="""
            Execute some cases. This always uses the first compiled simulator
            (the artefacts under '<WORKDIR>/<DESIGN>/<CONFIG>/compile-0/'),
            and runs compilation if that has not yet been compiled successfully.
            """,
        allow_abbrev=False,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.set_defaults(entryPoint=main)
    parser.add_argument(
        "--cases",
        help="Cases to run",
        type=ArgPatternMatcher("cases", lambda: CTX.availableCases, casesByTag),
        required=True,
        metavar="CASES",
    )
    parser.add_argument(
        "--compileArgs",
        help="""
            Extra options to add to the end of the compilation command line.
            Provided as a single string that will undergo shell word splitting,
            but no other procssing (no globs or variable substitution).
        """,
        type=shlex.split,
        metavar="STRING",
        action="extend",
        default=[],
    )
    parser.add_argument(
        "--executeArgs",
        help="""
            Extra options to pass to the simulator executable.
            Provided as a single string that will undergo shell word splitting,
            but no other procssing (no globs or variable substitution).
        """,
        type=shlex.split,
        metavar="STRING",
        action="extend",
        default=[],
    )
    parser.add_argument(
        "--nCompile",
        help="Number of times to repeat compilation",
        type=ArgRangedInt(1, None),
        default=1,
        metavar="N",
    )
    parser.add_argument(
        "--nExecute",
        help="Number of times to repeat execution",
        type=ArgRangedInt(0, None),
        default=1,
        metavar="N",
    )
    parser.add_argument("--retry", help="Retry steps that failed earleir", action="store_true")
    parser.add_argument(
        "--timeout",
        help="Fail with a timeout after the specified number of minutes",
        type=ArgRangedInt(1, None),
        default=None,
        metavar="MINUTES",
    )
    parser.add_argument("--verbose", help="Report more info about the process", action="store_true")

    parserWorkRootGroup = parser.add_argument_group("Options to specify working directory")
    parserWorkRootGroup.add_argument(
        "--compileRoot",
        help="Root of working directory for compilation only, value of --workRoot by default",
        type=os.path.abspath,
        metavar="DIR",
    )
    parserWorkRootGroup.add_argument(
        "--executeRoot",
        help="Root of working directory for execution only, value of --workRoot by default",
        type=os.path.abspath,
        metavar="DIR",
    )
    parserWorkRootGroup.add_argument(
        "--workRoot",
        help="Root of working directory for compilation and execution",
        type=os.path.abspath,
        default=CTX.defaultWorkDir,
        metavar="DIR",
    )
