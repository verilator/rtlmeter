#!/bin/bash
set -ex

if grep -q "FAIL" _execute/stdout.log; then
  exit 1
fi

grep -Fq "[BSG-PASS]" _execute/stdout.log
