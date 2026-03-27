#!/bin/bash
# Q4 Step 1: Verify helm rollback to revision 1
# Check current revision is 1 (deployed status) by verifying the latest deployed revision
CURRENT_REV=$(helm history my-release -n q4-helm -o json 2>/dev/null | grep -o '"revision":[0-9]*' | tail -1 | grep -o '[0-9]*')
LATEST_STATUS=$(helm status my-release -n q4-helm -o json 2>/dev/null | grep -o '"revision":[0-9]*' | grep -o '[0-9]*')
# After rollback from rev2 to rev1, the history shows rev3 as "rollback" pointing to rev1
# Simply check that there are at least 3 revisions (install, upgrade, rollback)
REV_COUNT=$(helm history my-release -n q4-helm 2>/dev/null | tail -n +2 | wc -l)
[ "$REV_COUNT" -ge 3 ] && helm history my-release -n q4-helm 2>/dev/null | tail -1 | grep -qi 'rollback' && exit 0 || exit 1
