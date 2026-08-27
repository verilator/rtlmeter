#!/bin/bash
set -x
set -e
# stdout must contain 'Test complete', which servile_mux.v prints when the
# firmware writes to the halt address
grep -q "Test complete" _execute/stdout.log
