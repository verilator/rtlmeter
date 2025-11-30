#!/bin/bash
set -x
set -e
# stdout must contain 'TESTCASE PASSED'
grep -q "TESTCASE PASSED" _execute/stdout.log
