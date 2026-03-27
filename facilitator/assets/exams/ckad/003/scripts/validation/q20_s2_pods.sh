#!/bin/bash
[ -f /tmp/q20-pods.txt ] || exit 1
grep -q 'broken-logger' /tmp/q20-pods.txt || exit 1
head -n 1 /tmp/q20-pods.txt | grep -q 'IP' || exit 1
head -n 1 /tmp/q20-pods.txt | grep -q 'NODE' && exit 0 || exit 1
