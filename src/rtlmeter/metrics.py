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

import json
import operator
import os
from dataclasses import dataclass
from typing import Callable, Dict, Final, List, Literal, TypeAlias, final

Step = Literal[
    "verilate",
    "cppbuild",
    "compile",
    "execute",
]


STEPS: Final[Dict[Step, str]] = {
    "verilate": "Running Verilator",
    "cppbuild": "Compiling Verilator output into executable",
    "compile": "'verilate' + 'cppbuild' combined together",
    "execute": "Running simulation",
}


# Returns a short pretty description of the step
def stepDescription(step: Step) -> str:
    return STEPS[step]


Metric = Literal[
    "elapsed",
    "cpu",
    "memory",
    "user",
    "system",
    "speed",
    "clocks",
    "traceSize",
    "ccacheHit",
    "codeSize",
]


@final
@dataclass(frozen=True)
class MetricDef:
    header: str  # Short descritpion usable as a table header
    unit: str  # Unit (dimension) of measurement
    accumulate: Callable[[float, float], float] | None  # Accumulate 2 samples
    identityValue: float | None  # Identity element of 'accumulate'
    higherIsBetter: bool | None  # Higher value is better
    description: str  # More detailed description of metric


# fmt: off
METRICS: Final[Dict[Metric, MetricDef]] = {
    "elapsed"   : MetricDef("Elapsed time", "s",            operator.add,   0,    False,
                            "Wall clock time elapsed during the step (time %e)"),
    "user"      : MetricDef("CPU User", "s",                operator.add,   0,    False,
                            "Cumulative CPU time used by the step in user mode (time %U)"),
    "system"    : MetricDef("CPU System", "s",              operator.add,   0,    False,
                            "Cumulative CPU time used by the step in kernel mode (time %S)"),
    "cpu"       : MetricDef("CPU Total", "s",               operator.add,   0,    False,
                            "Sum of CPU User + CPU System"),
    "memory"    : MetricDef("Peak memory", "MB",            max,            0,    False,
                            "Maximum resident set size durint the step (time %M)"),
    "speed"     : MetricDef("Sim speed", "kHz",             None,           None, True,
                            "Frequency of main clock during simulation "
                            "(simulated clock cycles / elapsed time)"),
    "clocks"    : MetricDef("Sim clock cycles", "count",    operator.add,   0,    None,
                            "Number of simulated main clock cycles "
                            "(deterministic, for sanity checking only)"),
    "traceSize" : MetricDef("Trace dump size", "MB",        operator.add,   0,    False,
                            "Size of trace dumps"),
    "ccacheHit" : MetricDef("ccache hit rate", "%",         None,           None, True,
                            "ccache hit rate during C++ compilation"),
    "codeSize"  : MetricDef("Code size", "MB",              operator.add,   0,    False,
                            "Total size of all generated hot code"),
}
#fmt : on


# Returns a short pretty description of the metric
def metricDef(metric: Metric) -> MetricDef:
    return METRICS[metric]


@final
@dataclass(frozen=True)
class Sample:
    value: float # value of sample
    file: str # Metrics file the sample came from


# Metrics are stored as a map from 'case' to 'step' to 'metric' to list of samples
Metrics : TypeAlias = Dict[str, Dict[Step, Dict[Metric, List[Sample]]]]


# Read all metrics from the given working directory and collate into single data structure
def collate(rootDir: str) -> Metrics:
    # The result
    allMetrics: Metrics = {}

    # Return subdirectories sorted by name
    def sortedSubDirs(dir: str) -> List[os.DirEntry]:
        return sorted((_ for _ in os.scandir(dir) if _.is_dir()), key=lambda _: _.name)

    # Recursively gather all metrics from directories.
    # Does not descend further once some metrics have been found.
    def gatherMetrics(dirs: List[os.DirEntry]) -> None:
        bottom = False
        for dir in dirs:
            if not dir.name.startswith("_"):
                continue
            metricsFile = os.path.join(dir.path, "metrics.json")
            if not os.path.exists(metricsFile):
                continue
            # Do not descend beyond the step root, especially not into obj_dir, which is huge
            bottom = True
            with open(metricsFile, "r", encoding="utf-8") as fd:
                allData = json.load(fd)
                for case, caseData in allData.items():
                    caseMetrics = allMetrics.setdefault(case, {})
                    for step, stepData in caseData.items():
                        stepMetrics = caseMetrics.setdefault(step, {})
                        for metric, value in stepData.items():
                            stepMetrics.setdefault(metric, []).append(Sample(value, metricsFile))
        if bottom:
            return
        # Descend
        for dir in dirs:
            gatherMetrics(sortedSubDirs(dir.path))

    # Gather from the root
    gatherMetrics(sortedSubDirs(rootDir))
    # Done
    return allMetrics


def load(dataPath: str) -> Metrics:
    # If directory, collate it
    if os.path.isdir(dataPath):
        return collate(dataPath)

    # Otherwise it's a collated JSON file, just load it
    with open(dataPath, "r", encoding="utf-8") as fd:
        allData = json.load(fd)["cases"]
    for caseData in allData.values():
        for stepData in caseData.values():
            for samples in stepData.values():
                samples[:] = map(lambda _ : Sample(_, dataPath), samples)
    return allData
