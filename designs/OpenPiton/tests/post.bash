#!/bin/bash
set -x
set -e
# stdout must contain 'All threads hit good trap - PASS'
grep -q "All threads hit good trap - PASS" _execute/stdout.log

