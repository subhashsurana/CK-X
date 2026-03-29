#!/usr/bin/env bash
set -euo pipefail
# Executes the script from `sunny_status_command.sh` and checks if it returns success
STATUS_FILE="/opt/course/exam4/p2/sunny_status_command.sh"

# Check if file exists
if [ ! -f "$STATUS_FILE" ]; then
    echo "Status command file does not exist"
    exit 1
fi

# Execute the command and capture output
OUT=$(bash "$STATUS_FILE" 2>/dev/null || true)

# It must actually describe the sunny pods
if echo "$OUT" | grep -qi "sunny" && echo "$OUT" | grep -qi "Running"; then
    exit 0
else
    echo "Status command output is missing 'sunny' pods or 'Running' state." >&2
    exit 1
fi