#!/bin/bash
set -x
set -e
# stdout must NOT contain 'FAIL' and must contain 'All cores finished! Terminating'
! grep -q "FAIL" _execute/stdout.log
grep -q "All cores finished! Terminating" _execute/stdout.log
