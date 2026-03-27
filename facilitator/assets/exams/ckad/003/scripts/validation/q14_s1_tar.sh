#!/bin/bash
file /opt/oci/local-alpine.tar | grep -q 'tar archive' && exit 0 || exit 1
