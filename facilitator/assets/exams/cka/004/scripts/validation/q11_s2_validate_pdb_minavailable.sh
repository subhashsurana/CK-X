#!/bin/bash
MIN=$(kubectl get pdb api-pdb -n availability -o jsonpath='{.spec.minAvailable}' 2>/dev/null)
if [[ "$MIN" != "2" ]]; then
  echo "api-pdb minAvailable is '$MIN'"; exit 1
fi
echo "api-pdb minAvailable is correct"; exit 0
