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
import datetime
import json
import os
import subprocess
import sys
from typing import Any, Final, List, final

import numpy as np
import scipy.stats
import tabulate
from sklearn.neighbors import LocalOutlierFactor

from rtlmeter import metrics, misc
from rtlmeter.context import CTX
from rtlmeter.subcommands.common import (
    ArgExistingDirectory,
    ArgExistingFileOrDirectory,
    ArgPatternMatcher,
    casesByTag,
)

tabulate.PRESERVE_WHITESPACE = True
tabulate.MIN_PADDING = 0


# Returns sample mean and it's confidence interval (or mean and None if there is only 1 sample)
def meanAndConfidenceInterval(samples, confidence=0.95):
    n = len(samples)
    assert n >= 1
    # Sample mean
    mean = float(np.mean(samples))
    if n == 1:
        return mean, None
    # Sample standard deviation
    stddev = np.std(samples, ddof=1)
    if stddev == 0:
        return mean, 0
    ci = float(
        scipy.stats.norm.interval(confidence=confidence, loc=0, scale=stddev / np.sqrt(n))[1]
    )
    return mean, ci


def formatMeanAndConfidenceInterval(mean, ci):
    meanStr = f"{mean:0.2f}"
    if ci is None or mean == 0:
        return meanStr + " " * 10
    # Convert to % of mean
    ci = 100.0 * ci / mean
    # Colorize
    ciStr = misc.styleByInterval(
        f"(±{ci:5.2f}%)", ci, "greenBold", 0.25, "green", 0.05, "plain", 2.0, "red", 5.0, "redBold"
    )
    return f"{meanStr} {ciStr}"


_ASCII_TABLE_FORMAT: Final = tabulate.TableFormat(
    lineabove=tabulate.Line("╒═", "═", "═╤═", "═╕"),
    linebelowheader=tabulate.Line("╞═", "═", "═╪═", "═╡"),
    linebelow=tabulate.Line("╘═", "═", "═╧═", "═╛"),
    headerrow=tabulate.DataRow("│ ", " │ ", " │"),
    datarow=tabulate.DataRow("│ ", " │ ", " │"),
    linebetweenrows=None,
    padding=0,
    with_header_hide=None,
)

_GITHUB_TABLE_FORMAT: Final = tabulate.TableFormat(
    lineabove=tabulate.Line("|", "-", "|", "|"),
    linebelowheader=tabulate.Line("|", "-", "|", "|"),
    linebetweenrows=None,
    linebelow=None,
    headerrow=tabulate.DataRow("|", "|", "|"),
    datarow=tabulate.DataRow("|", "|", "|"),
    padding=1,
    with_header_hide=["lineabove"],
)


def printTable(table: List[List[str]], format: misc.Format, **kwargs) -> None:
    if format == "ascii":
        print(tabulate.tabulate(table, tablefmt=_ASCII_TABLE_FORMAT, **kwargs))
    elif format == "github":
        print(tabulate.tabulate(table, tablefmt=_GITHUB_TABLE_FORMAT, **kwargs))
    else:
        raise RuntimeError("unreachable")


def reportMain(args: argparse.Namespace) -> None:
    misc.setFormat(args.format)

    allData = metrics.load(args.dataPath)

    cases = sorted(set(args.cases + [_.rpartition(":")[0] for _ in args.cases]))

    for step in args.steps:
        # Gather metrics available in this step
        availableMetrics = list(args.metrics)
        for case in cases:
            if case not in allData:
                continue
            caseData = allData[case]
            if step not in caseData:
                continue
            stepData = caseData[step]
            sampleSizes = set(len(_) for _ in stepData.values())
            assert len(sampleSizes) == 1, "Inconsistent sample count"
            availableMetrics = list(filter(stepData.__contains__, availableMetrics))
        if not availableMetrics:
            continue

        # Build the table
        table: List[List[str]] = []
        mDefs = [metrics.metricDef(_) for _ in availableMetrics]
        allRow = [_.identityValue for _ in mDefs]
        for case in cases:
            if case not in allData:
                continue
            caseData = allData[case]
            if step not in caseData:
                continue
            stepData = caseData[step]
            row = [case, len(stepData[availableMetrics[0]])]
            for i, metric in enumerate(availableMetrics):
                mean, ci = meanAndConfidenceInterval([_.value for _ in stepData[metric]])
                row.append(formatMeanAndConfidenceInterval(mean, ci))
                if (accumulate := mDefs[i].accumulate) is not None:
                    allRow[i] = accumulate(allRow[i], mean)
            table.append(row)

        if not table:
            continue

        table.append(tabulate.SEPARATING_LINE)
        table.append(
            ["All", ""]
            + [formatMeanAndConfidenceInterval(_, None) if _ is not None else "" for _ in allRow]
        )

        # Print the table
        headers = ["Case", "#"]
        for metric in availableMetrics:
            metricDef = metrics.metricDef(metric)
            headers.append(f"{metricDef.header} [{metricDef.unit}]")

        print()
        print(misc.styled(step, style="bold"))
        printTable(
            table,
            args.format,
            headers=headers,
            disable_numparse=True,
            colalign=["left"] + ["right"] * (len(headers) - 1),
        )


def compareMain(args: argparse.Namespace) -> None:
    misc.setFormat(args.format)

    aAllData = metrics.load(args.aDataPath)
    bAllData = metrics.load(args.bDataPath)

    cases = sorted(set(args.cases + [_.rpartition(":")[0] for _ in args.cases]))
    commonCases = sorted(_ for _ in cases if _ in aAllData and _ in bAllData)
    if not commonCases:
        print("No cases specified exist in both runs")
        sys.exit(0)

    gainStyle: Any = ("redBold", 0.9, "red", 0.95, "plain", 1.05, "green", 1.1, "greenBold")
    for step in args.steps:
        for metric in args.metrics:
            metricDef = metrics.metricDef(metric)
            # Build the table
            table: List[List[str]] = []
            gains = []
            sigGains = []
            for case in commonCases:
                aCaseData = aAllData[case]
                bCaseData = bAllData[case]
                if step not in aCaseData or step not in bCaseData:
                    continue
                aStepData = aCaseData[step]
                bStepData = bCaseData[step]
                assert len(set(len(_) for _ in aStepData.values())) == 1, (
                    "Inconsitent sample count in A"
                )
                assert len(set(len(_) for _ in bStepData.values())) == 1, (
                    "Inconsitent sample count in B"
                )
                if metric not in aStepData or metric not in bStepData:
                    continue
                aData = [_.value for _ in aStepData[metric]]
                bData = [_.value for _ in bStepData[metric]]

                aN = len(aData)
                bN = len(bData)
                aMean = np.mean(aData)
                bMean = np.mean(bData)

                # Ignore cases with very small means (e.g.: example:* or *:hello)
                # These would have a big effect on 'gain' and hide the truth
                if aMean <= 1e-3 or bMean <= 1e-3:
                    continue

                gain = bMean / aMean if metricDef.higherIsBetter else aMean / bMean
                gainStr = misc.styleByInterval(f"{gain:.2f}x", gain, *gainStyle)
                gains.append(gain)

                pValStr = ""
                if aN >= 2 and bN >= 2:
                    # Need to handle degenerate cases where all samples are the same.
                    # This can happen with coarse granularity metrics like memory usage.
                    allSameA = all(_ == aData[0] for _ in aData)
                    allSameB = all(_ == bData[0] for _ in bData)
                    if allSameA and allSameB:
                        pVal = 0.0 if aData[0] != bData[0] else 1.0
                    elif allSameA:
                        # t-test for difference of mean of B from constant A
                        pVal = scipy.stats.ttest_1samp(bData, aData[0], nan_policy="raise").pvalue
                    elif allSameB:
                        # t-test for difference of mean of A from constant B
                        pVal = scipy.stats.ttest_1samp(aData, bData[0], nan_policy="raise").pvalue
                    else:
                        # This performs Welch's t-test for the difference in population mean
                        pVal = scipy.stats.ttest_ind(
                            aData, bData, equal_var=False, nan_policy="raise"
                        ).pvalue
                    pValStr = misc.styleByInterval(
                        f"{pVal:.2f}",
                        pVal,
                        "greenBold",
                        0.025,
                        "green",
                        0.05,
                        "plain",
                        0.1,
                        "red",
                        0.2,
                        "redBold",
                    )
                    if pVal < 0.05:
                        sigGains.append(gain)

                table.append(
                    [
                        case,
                        str(len(aData)),
                        str(len(bData)),
                        formatMeanAndConfidenceInterval(*meanAndConfidenceInterval(aData)),
                        formatMeanAndConfidenceInterval(*meanAndConfidenceInterval(bData)),
                        gainStr,
                        pValStr,
                    ]
                )

            if not table:
                continue

            table.append(tabulate.SEPARATING_LINE)
            meanGain = scipy.stats.gmean(gains)
            meanGainStr = misc.styleByInterval(f"{meanGain:.2f}x", meanGain, *gainStyle)
            table.append(["Geometric mean", "", "", "", "", meanGainStr, ""])
            if sigGains:
                meanGain = scipy.stats.gmean(sigGains)
                meanGainStr = misc.styleByInterval(f"{meanGain:.2f}x", meanGain, *gainStyle)
                table.append(["Geometric mean - pVal < 0.05", "", "", "", "", meanGainStr, ""])

            # Print the table
            hilo = (
                "should be equal"
                if metricDef.higherIsBetter is None
                else "higher is better"
                if metricDef.higherIsBetter
                else "lower is better"
            )
            print()
            print(
                misc.styled(
                    f"{step} - {metricDef.header} [{metricDef.unit}] - {hilo}", style="bold"
                )
            )
            printTable(
                table,
                args.format,
                headers=[
                    "Case",
                    "#A",
                    "#B",
                    "Mean A",
                    "Mean B",
                    f"Gain ({'B/A' if metricDef.higherIsBetter else 'A/B'})",
                    "p-value",
                ],
                disable_numparse=True,
                colalign=["left"] + ["right"] * (len(table[0]) - 1),
            )


def rawdataMain(args: argparse.Namespace) -> None:
    misc.setFormat(args.format)

    allData = metrics.load(args.dataPath)

    cases = sorted(set(args.cases + [_.rpartition(":")[0] for _ in args.cases]))

    zIntervals: Any = ("plain", 1.0, "yellow", 2.0, "red", 3.0, "redBold")

    for step in args.steps:
        for metric in args.metrics:
            # Build the table
            table: List[List[str]] = []
            for case in cases:
                if case not in allData:
                    continue
                caseData = allData[case]
                if step not in caseData:
                    continue
                stepData = caseData[step]
                if metric not in stepData:
                    continue

                samples = stepData[metric]
                n = len(samples)
                # Make up some defautls that will display correctly if not enough samples
                zscores = [None for _ in samples]
                outlierVotes = [0 for _ in samples]
                if n >= 2:
                    zscores = scipy.stats.zscore(
                        [_.value for _ in samples], ddof=1, nan_policy="raise"
                    )
                if n >= 4:
                    # Add a bit of dithering to split quantized samples
                    rng = np.random.default_rng(seed=9876)
                    values = [[_.value + rng.normal(scale=1e-4)] for _ in samples]
                    # Run with up to 9 neighborhood sizes
                    minNeighbours = max(int(np.sqrt(n)), 3)
                    maxNeighbours = n - 1
                    for i in np.unique(np.linspace(minNeighbours, maxNeighbours, 9, dtype=int)):
                        lof = LocalOutlierFactor(n_neighbors=i, algorithm="brute")
                        for j, prediction in enumerate(lof.fit_predict(values)):
                            if prediction == -1:
                                outlierVotes[j] += 1

                if table:
                    table.append(tabulate.SEPARATING_LINE)
                metricsFile = (
                    (lambda _: os.path.relpath(_, args.dataPath))
                    if os.path.isdir(args.dataPath)
                    else (lambda _: "*collated*")
                )
                for s, z, o in zip(samples, zscores, outlierVotes):
                    vStr = misc.styleByInterval(f"{s.value:0.2f}", np.abs(z or 0.0), *zIntervals)
                    zStr = f"{z:0.3f}" if z is not None else ""
                    table.append([case, vStr, zStr, "+" * o, metricsFile(s.file)])

            if not table:
                continue

            # Print the table
            metricDef = metrics.metricDef(metric)
            print()
            print(misc.styled(f"{step} - {metricDef.header} [{metricDef.unit}]", style="bold"))
            printTable(
                table,
                args.format,
                headers=["Case", "Value", "Z-score", "Outlier", "Metrics file"],
                disable_numparse=True,
                colalign=["left", "right", "right", "right", "left"],
            )


def collateMain(args: argparse.Namespace) -> None:
    # Include the current date and time
    now = datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0)

    # Include git revsion or RTLMeter
    rltmeterVersion = subprocess.run(
        [  # Command
            "git",
            f"--git-dir={os.path.join(CTX.rootDir, '.git')}",
            "describe",
            "--always",
            "--dirty=-dirty",
            "--abbrev=16",
        ],
        capture_output=True,
        check=True,
        encoding="utf-8",
    ).stdout.strip()

    # Include Verilator version
    verilatorVersion = subprocess.run(
        [  # Command
            "verilator",
            "--version",
        ],
        capture_output=True,
        check=True,
        encoding="utf-8",
    ).stdout.strip()

    # Include cpuinfo
    with open("/proc/cpuinfo", "r", encoding="utf-8") as fd:
        # Ignore variable lines
        cpuinfo = "".join(line for line in fd if "cpu MHz" not in line)

    # Include step and metric descriptions for downstream tools
    allSteps = {
        _: {  #
            "description": metrics.stepDescription(_)
        }
        for _ in list(sorted(metrics.STEPS.keys()))
    }
    allMetrics = {
        _: {  #
            "header": metrics.metricDef(_).header,
            "unit": metrics.metricDef(_).unit,
            "higherIsBetter": metrics.metricDef(_).higherIsBetter,
            "description": metrics.metricDef(_).description,
        }
        for _ in list(sorted(metrics.METRICS.keys()))
    }

    # Gather data from working directory
    caseData = metrics.load(args.dir)

    # Assemble final record
    result = {
        "date": now.isoformat(),
        "RTLMeterVersion": rltmeterVersion,
        "VerilatorVersion": verilatorVersion,
        "cpuinfo": cpuinfo,
        "steps": allSteps,
        "metrics": allMetrics,
        "cases": caseData,
    }

    # Add run name provided on command line
    if args.runName is not None:
        result["runName"] = args.runName

    @final
    class Encoder(json.JSONEncoder):
        def default(self, o):
            if isinstance(o, metrics.Sample):
                return o.value
            return super().default(o)

    print(json.dumps(result, indent=2, sort_keys=True, cls=Encoder))


def addCommonArgs(parser: argparse.ArgumentParser) -> None:
    parser.add_argument(
        "--cases",
        help="Report only the specified cases",
        type=ArgPatternMatcher("cases", lambda: CTX.availableCases, casesByTag),
        metavar="CASES",
        default="*",
    )
    parser.add_argument(
        "--format",
        help="Output formatting, one of: %(choices)s",
        metavar="FMT",
        choices=["ascii", "github"],
        default="ascii",
    )


def addSubcommands(subparsers) -> None:
    # Subcommand "report"
    reportParser: argparse.ArgumentParser = subparsers.add_parser(
        "report",
        help="Report metrics gathered in working directory",
        allow_abbrev=False,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    reportParser.set_defaults(entryPoint=reportMain)
    addCommonArgs(reportParser)
    reportParser.add_argument(
        "--metrics",
        help="Metrics to report",
        type=ArgPatternMatcher("metrics", metrics.METRICS.keys),
        metavar="METRICS",
        default="speed elapsed memory",
    )
    reportParser.add_argument(
        "--steps",
        help="Steps to report",
        type=ArgPatternMatcher("steps", metrics.STEPS.keys),
        metavar="STEPS",
        default="verilate execute",
    )
    reportParserDirGroup = reportParser.add_mutually_exclusive_group()
    reportParserDirGroup.add_argument(
        "dataPath",
        help="Work directory of run, or collated data file",
        type=ArgExistingFileOrDirectory(),
        default=CTX.defaultWorkDir,
        metavar="DATA",
        nargs="?",
    )

    # Subcommand "compare"
    compareParser: argparse.ArgumentParser = subparsers.add_parser(
        "compare",
        help="Compare metrics in two different working directories",
        allow_abbrev=False,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    compareParser.set_defaults(entryPoint=compareMain)
    addCommonArgs(compareParser)
    compareParser.add_argument(
        "--metrics",
        help="Metrics to compare",
        type=ArgPatternMatcher("metrics", metrics.METRICS.keys),
        metavar="METRICS",
        default="elapsed",
    )
    compareParser.add_argument(
        "--steps",
        help="Steps to compare",
        type=ArgPatternMatcher("steps", metrics.STEPS.keys),
        metavar="STEPS",
        default="verilate execute",
    )
    compareParser.add_argument(
        "aDataPath",
        help="Working director, or collated data file of first run (A)",
        type=ArgExistingFileOrDirectory(),
        metavar="ADATA",
    )
    compareParser.add_argument(
        "bDataPath",
        help="Working director, or collated data file of second run (B)",
        type=ArgExistingFileOrDirectory(),
        metavar="BDATA",
    )

    # Subcommand "rawdata"
    rawdataParser: argparse.ArgumentParser = subparsers.add_parser(
        "rawdata",
        help="Display raw metrics gathered in working directory",
        allow_abbrev=False,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    rawdataParser.set_defaults(entryPoint=rawdataMain)
    addCommonArgs(rawdataParser)
    rawdataParser.add_argument(
        "--metrics",
        help="Metrics to report",
        type=ArgPatternMatcher("metrics", metrics.METRICS.keys),
        metavar="METRICS",
        default="speed elapsed memory",
    )
    rawdataParser.add_argument(
        "--steps",
        help="Steps to report",
        type=ArgPatternMatcher("steps", metrics.STEPS.keys),
        metavar="STEPS",
        default="verilate execute",
    )
    rawdataParser.add_argument(
        "dataPath",
        help="Work directory of run, or collated data file",
        type=ArgExistingFileOrDirectory(),
        default=CTX.defaultWorkDir,
        metavar="DATA",
        nargs="?",
    )

    # Subcommand "collate"
    collateParser: argparse.ArgumentParser = subparsers.add_parser(
        "collate",
        help="Collect and combine metrics gathered in working directory",
        description="Print collated JSON data to stdout.",
        allow_abbrev=False,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    collateParser.set_defaults(entryPoint=collateMain)
    collateParser.add_argument(
        "--runName",  #
        help="Add 'runName' entry to output",
        type=str,
        metavar="NAME",
        default=None,
    )
    collateParser.add_argument(
        "dir",
        help="Work directory of run",
        type=ArgExistingDirectory(),
        default=CTX.defaultWorkDir,
        metavar="DIR",
        nargs="?",
    )
