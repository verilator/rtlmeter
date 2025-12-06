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
import os
import shlex
import stat
import subprocess
import sys
import time
from typing import Dict, Final, List

from rtlmeter import misc
from rtlmeter.context import CTX

_TIMEFORMAT: Final[str] = """{
    "elapsed" : %e,
    "user" : %U,
    "system" : %S,
    "memory" : %M
}
"""


TIME_CMD = "time"
if sys.platform == "darwin":
    TIME_CMD = "gtime"  # On macOS use GNU time


def runcmd(
    cmd: List[str],  # Command + arguments
    tag: str,  # Tag string to use for log and marker files
    extraEnv: Dict[str, str] | None = None,  # Additional environment variables
) -> bool:
    tagDir = f"_{tag}"
    os.makedirs(tagDir, exist_ok=True)

    cmd = list(map(shlex.quote, cmd))

    # Write the command out for easier debugging of the steps
    cmdFileName = os.path.join(tagDir, "cmd")
    with open(cmdFileName, "w", encoding="utf-8") as cmdFile:
        cmdFile.write("#!/bin/sh\n")
        cmdFile.write(" ".join(cmd))
        cmdFile.write(' "$@"\n')
    os.chmod(cmdFileName, os.stat(cmdFileName).st_mode | stat.S_IEXEC | stat.S_IXGRP)

    # Add extraEnv
    env = os.environ.copy()
    if extraEnv is not None:
        env.update(extraEnv)

    cwd = os.getcwd()
    logFile = os.path.join(tagDir, "stdout.log")

    # Tell the user where the stdout log is, and how they can reproduce the command
    misc.echo(f"CWD: {cwd}")
    misc.echo(f"LOG: {os.path.join(cwd, logFile)}")
    misc.echo(f"CMD: {' '.join(cmd)}", style="magenta")

    # Actual command line to run, using the cmd file
    timeFile = os.path.join(tagDir, "time.json")
    cmd = [TIME_CMD, "-o", timeFile, "-f", _TIMEFORMAT, cmdFileName]

    # Apply timeout if a deadline is set
    if (timeout := CTX.timeout()) is not None:
        # If already passed, fail now
        if timeout == 0:
            misc.error("Timeout deadline already passed")
            return False
        cmd = ["timeout", "-v", "-s", "KILL", f"{timeout}s"] + cmd

    # Base of time stamps in stdout log
    startTime = time.monotonic_ns()

    # Start the process
    with subprocess.Popen(
        args=cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        env=env,
    ) as process:
        # Gather stdout/stderr into the logfile, prefixed by time stamps for each line
        with open(logFile, "w", encoding="utf-8") as fd:
            assert process.stdout, "stdout is None"
            for line in process.stdout:
                timeStamp = (time.monotonic_ns() - startTime) / 1e9
                line = f"{timeStamp:8.2f} | {line}"
                fd.write(line)
                if CTX.verbose:
                    print(line, end="")

    # If failed, we are done
    if process.returncode != 0:
        return False

    # Tweak the data recorded by 'time'
    with open(timeFile, "r", encoding="utf-8") as fd:
        tData = json.load(fd)
        # Add 'user' + 'system' time as total 'cpu' time
        tData["cpu"] = tData["user"] + tData["system"]
        # Adjust 'memory to be in MB instead of KB
        tData["memory"] *= 1e-3
        # Make sure values are non-zero to avoid division by zero later
        tData = {k: max(v, 1e-2) for k, v in tData.items()}
    with open(timeFile, "w", encoding="utf-8") as fd:
        json.dump(tData, fd)

    # Finished successfully
    return True
