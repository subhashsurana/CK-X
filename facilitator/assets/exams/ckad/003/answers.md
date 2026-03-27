# CKAD Comprehensive Lab - 3 (CKAD-003) Answers

This document contains solutions for the CKAD-003 lab.

## Question 1: The Sidecar Surgery

```bash
kubectl create namespace q1-sidecar
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-pod
  namespace: q1-sidecar
spec:
  containers:
  - name: app
    image: busybox
    command: ['sh', '-c', 'while true; do sleep 3600; done']
  initContainers:
  - name: sidecar
    image: nginx:alpine
    restartPolicy: Always
EOF
```

## Question 2: The Config Switchboard

```bash
kubectl create namespace q2-config
kubectl create configmap app-config -n q2-config --from-literal=PORT=8080 --from-literal=THEME=dark

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: config-pod
  namespace: q2-config
spec:
  containers:
  - name: nginx
    image: nginx
    env:
    - name: APP_PORT
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: PORT
    volumeMounts:
    - name: config-volume
      mountPath: /etc/app-config
  volumes:
  - name: config-volume
    configMap:
      name: app-config
EOF
```

## Question 3: The API Archaeologist

```bash
# Edit the manifest to upgrade the API version
sed 's|batch/v1beta1|batch/v1|g' /tmp/old-cronjob.yaml > /tmp/new-cronjob.yaml

# Apply the new manifest in the q3-api namespace
kubectl apply -f /tmp/new-cronjob.yaml -n q3-api
```

## Question 4: The Helm Expedition

```bash
# Upgrade the release
helm upgrade my-release bitnami/nginx -n q4-helm --set image.repository=nginx,image.tag=1.25.0

# Rollback the release to revision 1
helm rollback my-release 1 -n q4-helm

# Export the history
helm history my-release -n q4-helm > /tmp/helm-history.txt
```

## Question 5: The Kustomize Kaleidoscope

```bash
# Create overlay directory
mkdir -p /tmp/kustomize-overlay

# Create kustomization.yaml
cat <<EOF > /tmp/kustomize-overlay/kustomization.yaml
resources:
- ../kustomize-base

replicas:
- name: web-app
  count: 3

configMapGenerator:
- name: web-config
  literals:
  - color=blue
EOF

# Apply the overlay
kubectl apply -k /tmp/kustomize-overlay -n q5-kustomize
```

## Question 6: The Blue-Green Bridge

```bash
# Identify the label used by the green deployment
kubectl get deploy app-green -n q6-blue-green -o yaml

# Edit the service to match the green selector instead of blue
# If blue used 'version: v1' and green used 'version: v2'
kubectl patch svc app-service -n q6-blue-green -p '{"spec":{"selector":{"version":"v2"}}}'
```

## Question 7: The Canary Cage

```bash
# Create the canary deployment
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-canary
  namespace: q7-canary
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
      track: canary
  template:
    metadata:
      labels:
        app: frontend
        track: canary
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
EOF
```

## Question 8: The Fortress

```bash
kubectl create namespace q8-security
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: secure-vault
  namespace: q8-security
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 2000
  containers:
  - name: nginx
    image: nginx:alpine
    securityContext:
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - NET_RAW
EOF
```

## Question 9: The Identity Crisis

```bash
# Create the ServiceAccount with automountServiceAccountToken set to false
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: api-reader
  namespace: q9-identity
automountServiceAccountToken: false
EOF

# Get the existing pod yaml, change the ServiceAccountName to api-reader, delete the old pod, and apply the new one.
kubectl get pod api-consumer -n q9-identity -o yaml > pod.yaml
# Edit pod.yaml:
# 1. Remove creationTimestamp, resourceVersion, uid
# 2. Change serviceAccountName to api-reader
# 3. Change serviceAccount to api-reader
kubectl delete pod api-consumer -n q9-identity
kubectl apply -f pod.yaml
```

## Question 10: The Traffic Director

```bash
kubectl create namespace q10-ingress

# 1. Create Ingress
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: main-ingress
  namespace: q10-ingress
  annotations:
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /\$2
spec:
  rules:
  - host: myapp.com
    http:
      paths:
      - path: /api(/|$)(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: api-svc
            port:
              number: 8080
EOF

# 2. Create ExternalName Service
kubectl create service externalname external-db --external-name database.external.com -n q10-ingress
```

## Question 11: The Observatory

```bash
kubectl create namespace q11-probes

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: slow-app
  namespace: q11-probes
spec:
  containers:
  - name: nginx
    image: nginx
    startupProbe:
      httpGet:
        path: /
        port: 80
      periodSeconds: 5
      failureThreshold: 20
    livenessProbe:
      httpGet:
        path: /health
        port: 80
      periodSeconds: 10
    readinessProbe:
      tcpSocket:
        port: 80
      periodSeconds: 5
EOF
```

## Question 12: The Network Lockdown

```bash
kubectl create namespace q12-network

# 1. Default Deny All
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: q12-network
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF

# 2. Allow Web
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-web
  namespace: q12-network
spec:
  podSelector:
    matchLabels:
      app: web
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: gateway
    ports:
    - protocol: TCP
      port: 80
EOF
```

## Question 13: The Persistent Bookshelf

```bash
# 1. Create the PVC
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: library-pvc
  namespace: q13-storage
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
EOF

# 2. Modify the Deployment
# Instead of modifying the live resource, we output to yaml, edit, and apply:
kubectl get deployment library -n q13-storage -o yaml > lib.yaml
# Edit lib.yaml to replace emptyDir: {} with persistentVolumeClaim: claimName: library-pvc under the correct volume name
kubectl apply -f lib.yaml
```

## Question 14: The Container Factory

```bash
# Prepare the workspace
mkdir -p /tmp/q14
mkdir -p /opt/oci

# Create the Dockerfile
cat <<EOF > /tmp/q14/Dockerfile
FROM alpine:latest
RUN echo "world" > /hello.txt
EOF

# Build the image
docker build -t local-alpine:v1 /tmp/q14

# Export the image as a tarball
docker save local-alpine:v1 -o /opt/oci/local-alpine.tar
```

## Question 15: The Cross-Namespace Corridor

```bash
kubectl create namespace q15-cross-ns

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: frontend-fixed
  namespace: q15-cross-ns
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    env:
    - name: BACKEND_URL
      value: "backend-svc.q15-backend.svc.cluster.local:8080"
EOF
```

## Question 16: The Admission Gatekeeper

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: limited-pod
  namespace: q16-quota
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sleep", "3600"]
    resources:
      requests:
        cpu: "100m"
        memory: "64Mi"
      limits:
        cpu: "200m"
        memory: "128Mi"
EOF
```

## Question 17: The Resilient Worker

```bash
kubectl create namespace q17-cron

cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: CronJob
metadata:
  name: strict-cron
  namespace: q17-cron
spec:
  schedule: "30 * * * *"
  concurrencyPolicy: Forbid
  startingDeadlineSeconds: 20
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: worker
            image: busybox
            command: ["date"]
          restartPolicy: OnFailure
EOF
```

## Question 18: The Broken Node

```bash
kubectl create namespace q18-affinity

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: batch-processor
  namespace: q18-affinity
spec:
  tolerations:
  - key: "type"
    operator: "Equal"
    value: "batch"
    effect: "NoSchedule"
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
  containers:
  - name: nginx
    image: nginx
EOF
```

## Question 19: The Vault Transfer

```bash
kubectl create namespace q19-secrets

kubectl create secret generic db-secret \
  -n q19-secrets \
  --from-literal=username=appuser \
  --from-literal=password=s3cur3

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: secret-reader
  namespace: q19-secrets
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sleep", "3600"]
    env:
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: password
EOF
```

## Question 20: The Signal Hunt

```bash
kubectl logs broken-logger -n q20-debug --previous > /tmp/q20-fatal.txt
kubectl get pods -n q20-debug -o wide > /tmp/q20-pods.txt
```

## Question 21: The API Extension Forge

```bash
cat <<EOF | kubectl apply -f -
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: widgets.apps.ckx.io
spec:
  group: apps.ckx.io
  scope: Namespaced
  names:
    plural: widgets
    singular: widget
    kind: Widget
    shortNames:
    - wdg
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            required:
            - image
            - replicas
            properties:
              image:
                type: string
              replicas:
                type: integer
EOF

cat <<EOF | kubectl apply -f -
apiVersion: apps.ckx.io/v1
kind: Widget
metadata:
  name: blue-widget
  namespace: q21-crd
spec:
  image: nginx:1.25
  replicas: 2
EOF
```
