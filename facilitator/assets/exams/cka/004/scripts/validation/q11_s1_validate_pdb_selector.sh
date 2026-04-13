#!/bin/bash
SELECTOR=$(kubectl get pdb api-pdb -n availability -o jsonpath='{.spec.selector.matchLabels.app}' 2>/dev/null)
if [[ "$SELECTOR" != "api" ]]; then
  echo "api-pdb selector app is '$SELECTOR'"; exit 1
fi
echo "api-pdb selector is correct"; exit 0
