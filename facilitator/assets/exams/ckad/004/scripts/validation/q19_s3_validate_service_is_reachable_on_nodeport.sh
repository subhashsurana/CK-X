#!/usr/bin/env bash
set -euo pipefail

NS="nodeport-30100"
SVC="jupiter-crew-svc"
NODEPORT=$(kubectl -n "${NS}" get svc "${SVC}" -o jsonpath='{.spec.ports[0].nodePort}')

if [[ -z "${NODEPORT}" ]]; then
  echo "Could not determine nodePort for ${SVC}" >&2
  exit 1
fi

get_node_ips() {
  kubectl get nodes -o json | jq -r '
    .items[].status.addresses[]
    | select(.type == "InternalIP" or .type == "ExternalIP")
    | .address
  ' | awk 'NF' | sort -u
}

probe_host() {
  local host=$1
  curl -fsS --max-time 5 "http://${host}:${NODEPORT}" >/dev/null 2>&1
}

probe_via_k8s_api_server() {
  local host=$1
  ssh -o StrictHostKeyChecking=no \
      -o UserKnownHostsFile=/dev/null \
      -o ConnectTimeout=5 \
      candidate@k8s-api-server \
      "curl -fsS --max-time 5 http://${host}:${NODEPORT} >/dev/null" >/dev/null 2>&1
}

NODE_IPS=$(get_node_ips)

for host in ${NODE_IPS}; do
  if probe_host "${host}"; then
    exit 0
  fi
done

# In this simulator the cluster runs nested behind k8s-api-server, so the jumphost
# may not have direct routing to node IPs. Fall back to probing from the cluster host.
for host in ${NODE_IPS} 127.0.0.1 localhost; do
  if probe_via_k8s_api_server "${host}"; then
    exit 0
  fi
done

echo "Service ${SVC} was not reachable on any node IP:${NODEPORT}" >&2
exit 1
