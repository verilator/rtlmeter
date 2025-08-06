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

import dataclasses
import enum
import os
import shutil
from dataclasses import dataclass
from typing import Any, Callable, Dict, List, final

from rtlmeter import misc


@final
@enum.unique
class CStatus(enum.Enum):
    SUCCESS_NOW = enum.auto()
    SUCCESS_BEFORE = enum.auto()
    FAILURE_NOW = enum.auto()
    FAILURE_BEFORE = enum.auto()
    FAILED_DEPENDENCY = enum.auto()

    def isSuccess(self) -> bool:
        if self == CStatus.SUCCESS_NOW:
            return True
        if self == CStatus.SUCCESS_BEFORE:
            return True
        return False


# Graph node
@final
@dataclass
class CNode:
    graph: "CGraph"
    id: int
    description: str
    workDir: str
    step: str
    computation: Callable[[], bool]
    oNodes: List = dataclasses.field(default_factory=list)  # Nodes that depend on this node
    iNodes: List = dataclasses.field(default_factory=list)  # Nodes that this node depends on

    def __eq__(self, other: Any) -> bool:
        return isinstance(other, CNode) and other.graph == self.graph and other.id == self.id

    def __hash__(self) -> int:
        return hash((self.graph, self.id))


# Computation Graph - DAG
@final
class CGraph:
    nodes: List[CNode] = []

    def addNode(
        self, description: str, workDir: str, step: str, computation: Callable[[], bool]
    ) -> CNode:
        node = CNode(
            graph=self,
            id=len(self.nodes),
            description=description,
            workDir=workDir,
            step=step,
            computation=computation,
        )
        self.nodes.append(node)
        return node

    def addEdge(self, src: CNode, dst: CNode) -> None:
        assert src.graph is self, "'src' not in this graph"
        assert dst.graph is self, "'dst' not in this graph"
        assert (dst in src.oNodes) == (src in dst.iNodes), "Inconsitent endges"
        if dst not in src.oNodes:
            src.oNodes.append(dst)
            dst.iNodes.append(src)

    @staticmethod
    def _run(node: CNode, retry: bool, status: Dict[CNode, CStatus], nNodes: int) -> CStatus:
        # Check if node already evaluated, and if so just return its status
        if node in status:
            return status[node]

        # Evaluate all dependencies
        allDependenciesPassed = True
        for d in node.iNodes:
            if not CGraph._run(d, retry, status, nNodes).isSuccess():
                allDependenciesPassed = False

        # Evaluate this node
        misc.echo(f"({len(status) + 1}/{nNodes}) {node.description}", style="bold")

        # If not all successful, report dependency failure
        if not allDependenciesPassed:
            misc.echo("=== Skipping due to failed dependency ===", style="yellow")
            status[node] = CStatus.FAILED_DEPENDENCY
            return CStatus.FAILED_DEPENDENCY

        # Actually do it in the target directory
        with misc.inDirectory(node.workDir):
            # Status file on disk
            tagDir = f"_{node.step}"
            statusFile = os.path.join(tagDir, "status")

            # Check if this node was already evaluated on an earlier run
            if os.path.exists(statusFile):
                with open(statusFile, "r", encoding="utf-8") as fd:
                    savedStatus = fd.read()
                    assert savedStatus in ("success", "failure"), "Status file is invalid"
                    if savedStatus == "success":
                        misc.echo("=== Skipping due to success on earlier run ===", style="green")
                        status[node] = CStatus.SUCCESS_BEFORE
                        return CStatus.SUCCESS_BEFORE
                    if not retry:
                        misc.echo("=== Skipping due to failure on earlier run ===", style="red")
                        status[node] = CStatus.FAILURE_BEFORE
                        return CStatus.FAILURE_BEFORE
                    misc.echo("Retrying after failure on earlier run", style="yellow")

            # Clear and create the tag directory
            shutil.rmtree(tagDir, ignore_errors=True)
            os.makedirs(tagDir)

            # Run the job
            success = node.computation()

            # Write the status file
            with open(statusFile, "w", encoding="utf-8") as fd:
                fd.write("success" if success else "failure")

            # Report and set node status
            if success:
                misc.echo("=== Success ===", style="green")
                status[node] = CStatus.SUCCESS_NOW
                return CStatus.SUCCESS_NOW
            misc.echo("=== FAILED ===", style="red")
            status[node] = CStatus.FAILURE_NOW
            return CStatus.FAILURE_NOW

    # Run all nodes, return map of node status
    def runAll(self, retry: bool) -> Dict[CNode, CStatus]:
        status: Dict[CNode, CStatus] = {}
        # Run in depth-first order, for more immediate final results
        for node in self.nodes:
            if not node.oNodes:
                assert node not in status, "Sink CNode already evaluated"
                CGraph._run(node, retry, status, len(self.nodes))
        assert len(status) == len(self.nodes)
        return status
