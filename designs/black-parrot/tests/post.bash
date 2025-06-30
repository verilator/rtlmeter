#!/bin/bash
set -x
set -e
# stdout must contain ''
grep -q "All cores finished! Terminating" _execute/stdout.log

