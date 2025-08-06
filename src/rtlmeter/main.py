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

import rtlmeter.subcommands.reporting
import rtlmeter.subcommands.run
import rtlmeter.subcommands.show
import rtlmeter.subcommands.validate

if __name__ == "__main__":
    # Create the command line parser
    parser = argparse.ArgumentParser(
        prog="rtlmeter", description="RTLMeter benchmark suite", allow_abbrev=False
    )
    subparsers = parser.add_subparsers(title="subcommands", required=True)

    # Add the subcommands
    rtlmeter.subcommands.show.addSubcommands(subparsers)
    rtlmeter.subcommands.run.addSubcommands(subparsers)
    rtlmeter.subcommands.reporting.addSubcommands(subparsers)
    rtlmeter.subcommands.validate.addSubcommands(subparsers)

    # Parse arguments and dispatch to entry point
    args = parser.parse_args()
    args.entryPoint(args)
