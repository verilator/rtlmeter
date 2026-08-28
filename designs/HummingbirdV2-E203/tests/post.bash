#!/bin/bash
set -x
set -e
# stdout must contain 'TEST_PASSED'
grep -q "TEST_PASSED" _execute/stdout.log
