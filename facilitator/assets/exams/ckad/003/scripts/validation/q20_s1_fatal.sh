#!/bin/bash
[ -f /tmp/q20-fatal.txt ] || exit 1
grep -Fxq 'FATAL: cache backend unavailable' /tmp/q20-fatal.txt && exit 0 || exit 1
