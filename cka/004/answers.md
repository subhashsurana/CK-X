# CKA Mock Exam 02 - Solutions

## Q1: Service DNS

```bash
kubectl run dns-check -n backend --image=busybox:1.36 --restart=Never -- \
  nslookup web-ui.frontend.svc.cluster.local
kubectl create configmap dns-answer -n backend \
  --from-literal=fqdn=web-ui.frontend.svc.cluster.local
```

## Q2: Deployment Rollback

```bash
kubectl rollout status deployment/payment-api -n payments
kubectl rollout undo deployment/payment-api -n payments
kubectl rollout status deployment/payment-api -n payments
```

## Q3: Secret Environment Variables

```bash
kubectl create secret generic db-credentials -n data \
  --from-literal=username=admin \
  --from-literal=password=s3cr3t

kubectl patch deployment db-client -n data --type=json -p='[
  {"op":"add","path":"/spec/template/spec/containers/0/env","value":[
    {"name":"DB_USERNAME","valueFrom":{"secretKeyRef":{"name":"db-credentials","key":"username"}}},
    {"name":"DB_PASSWORD","valueFrom":{"secretKeyRef":{"name":"db-credentials","key":"password"}}}
  ]}
]'
kubectl rollout status deployment/db-client -n data
```

## Q4: DaemonSet

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-logger
  namespace: logging
spec:
  selector:
    matchLabels:
      app: node-logger
  template:
    metadata:
      labels:
        app: node-logger
    spec:
      containers:
      - name: logger
        image: busybox:1.36
        command: ["sh", "-c", "while true; do echo logging; sleep 3600; done"]
```

## Q5: Service Selector

```bash
kubectl patch service api-service -n troubleshooting \
  -p '{"spec":{"selector":{"app":"api-server"}}}'
kubectl get endpoints api-service -n troubleshooting
```

## Q6: ConfigMap Update

```bash
kubectl create configmap app-config -n appconfig \
  --from-literal=LOG_LEVEL=debug \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl rollout restart deployment/config-consumer -n appconfig
kubectl rollout status deployment/config-consumer -n appconfig
```

## Q7: PriorityClass

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: batch-priority
value: 5000
globalDefault: false
description: Priority class for batch worker pods
---
apiVersion: v1
kind: Pod
metadata:
  name: batch-worker
  namespace: default
spec:
  priorityClassName: batch-priority
  containers:
  - name: worker
    image: busybox:1.36
    command: ["sleep", "3600"]
```

## Q8: NodePort Service

```bash
kubectl expose deployment public-web -n services \
  --name=public-web --type=NodePort --port=80 --target-port=80
kubectl get service public-web -n services
```

## Q9: CronJob

```bash
kubectl create cronjob cleanup-job -n batch \
  --image=busybox:1.36 \
  --schedule='*/5 * * * *' \
  -- sh -c 'rm -rf /tmp/cache/*'
```

## Q10: CertificateSigningRequest

```bash
openssl genrsa -out /tmp/dev-user.key 2048
openssl req -new -key /tmp/dev-user.key -out /tmp/dev-user.csr -subj "/CN=dev-user"
CSR=$(base64 -w0 /tmp/dev-user.csr)
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: dev-user-csr
spec:
  request: ${CSR}
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF
kubectl certificate approve dev-user-csr
```

## Q11: PodDisruptionBudget

```bash
kubectl create pdb api-pdb -n availability --selector=app=api --min-available=2
```

## Q12: CustomResourceDefinition

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: widgets.platform.example.com
spec:
  group: platform.example.com
  scope: Namespaced
  names:
    plural: widgets
    singular: widget
    kind: Widget
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        x-kubernetes-preserve-unknown-fields: true
```

## Q13: Restricted Pod Security

```bash
kubectl label namespace restricted-ops \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/warn=restricted

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: restricted-nginx
  namespace: restricted-ops
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: nginx
    image: nginx:1.27
    command: ["sh", "-c", "sleep 3600"]
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop: [ALL]
EOF
```

## Q14: StorageClass and PVC

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-local
provisioner: rancher.io/local-path
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: fast-data
  namespace: storage
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: fast-local
  resources:
    requests:
      storage: 1Gi
```

## Q15: Resource Governance

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: governance-quota
  namespace: governance
spec:
  hard:
    pods: "10"
    requests.cpu: "2"
    requests.memory: 2Gi
---
apiVersion: v1
kind: LimitRange
metadata:
  name: governance-limits
  namespace: governance
spec:
  limits:
  - type: Container
    defaultRequest:
      cpu: 100m
      memory: 128Mi
```
