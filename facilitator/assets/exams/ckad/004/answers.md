# CKAD-004 Lab Answers

This document contains solutions or reference commands for all questions in the CKAD-004 lab. Paths follow `/opt/course/exam4/qXX/` and preview paths `/opt/course/exam4/p{1..3}/`.

## Question 1
**Question:** The DevOps team would like to get the list of all Namespaces in the cluster. Save the list to `/opt/course/exam4/q01/namespaces` on localhost.

**Answer:**
```bash
mkdir -p /opt/course/exam4/q01
kubectl get ns > /opt/course/exam4/q01/namespaces
```

## Question 2
**Question:** Create a single Pod of image `httpd:2.4.41-alpine` in Namespace `single-pod`. The Pod should be named `pod1` and the container should be named `pod1-container`. Write a kubectl command that outputs the status of that exact Pod to `/opt/course/exam4/q02/pod1-status-command.sh`.

**Answer:**
```bash
kubectl create ns single-pod || true
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: pod1
  namespace: single-pod
spec:
  containers:
  - name: pod1-container
    image: httpd:2.4.41-alpine
EOF

mkdir -p /opt/course/exam4/q02
cat > /opt/course/exam4/q02/pod1-status-command.sh <<'EOF'
#!/usr/bin/env bash
kubectl -n single-pod get pod pod1 -o jsonpath='{.status.phase}'
EOF
chmod +x /opt/course/exam4/q02/pod1-status-command.sh
```

## Question 3
**Question:** Create a Job manifest at `/opt/course/exam4/q03/job.yaml` named `neb-new-job` in namespace `jobs` that runs image `busybox:1.31.0` with command `sleep 2 && echo done`, sets `completions=3`, `parallelism=2`, and labels pods with `id=awesome-job`. Start the Job. The container should be named `neb-new-job-container`.

**Answer:**
```bash
kubectl create ns jobs || true
mkdir -p /opt/course/exam4/q03
cat > /opt/course/exam4/q03/job.yaml <<'EOF'
apiVersion: batch/v1
kind: Job
metadata:
  name: neb-new-job
  namespace: jobs
spec:
  completions: 3
  parallelism: 2
  template:
    metadata:
      labels:
        id: awesome-job
    spec:
      restartPolicy: OnFailure
      containers:
      - name: neb-new-job-container
        image: busybox:1.31.0
        command: ["/bin/sh","-c","sleep 2 && echo done"]
EOF
kubectl apply -f /opt/course/exam4/q03/job.yaml
```

## Question 4
**Question:** Using `helm` in Namespace `helm`: delete release `internal-issue-report-apiv1`, upgrade release `internal-issue-report-apiv2` to any newer `bitnami/nginx`, and install a new release `internal-issue-report-apache` from `bitnami/apache` with `replicas=2` via values.

**Answer:**
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami || true
helm repo update
helm -n helm uninstall internal-issue-report-apiv1 || true
helm -n helm upgrade --install internal-issue-report-apiv2 bitnami/nginx \
  --set fullnameOverride=internal-issue-report-apiv2
helm -n helm upgrade --install internal-issue-report-apache bitnami/apache \
  --set fullnameOverride=internal-issue-report-apache \
  --set replicaCount=2

```

## Question 5
**Question:** A ServiceAccount named `neptune-sa-v2` exists in `service-accounts`. Create a bound token for this ServiceAccount using `kubectl create token` with `--audience=api` and write it to `/opt/course/exam4/q05/token` on localhost (single line).

**Answer:**
```bash
# Ensure namespace and SA exist (seeded in setup, but safe to re-run)
kubectl create ns service-accounts || true
kubectl -n service-accounts create sa neptune-sa-v2 || true
mkdir -p /opt/course/exam4/q05

# Create a bound token with audience=api and a reasonable duration
kubectl -n service-accounts create token neptune-sa-v2 \
  --audience=api \
  --duration=1h \
  > /opt/course/exam4/q05/token

# Quick self-check (optional): should print the SA identity
kubectl auth whoami --token="$(tr -d '\r\n' < /opt/course/exam4/q05/token)"
```

## Question 6
**Question:** Create Pod `pod6` in Namespace `readiness` using `busybox:1.31.0` with readinessProbe executing `cat /tmp/ready` (initialDelaySeconds=`5`, periodSeconds=`10`). Ensure the container creates `/tmp/ready` and keeps running (for example: `touch /tmp/ready && sleep 1d`). Any equivalent command/args form is acceptable. Confirm the Pod becomes Ready.

**Answer:**
```bash
kubectl create ns readiness || true
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: pod6
  namespace: readiness
spec:
  containers:
  - name: c
    image: busybox:1.31.0
    command: ["/bin/sh","-c","touch /tmp/ready && sleep 1d"]
    readinessProbe:
      exec:
        command: ["/bin/sh","-c","cat /tmp/ready"]
      initialDelaySeconds: 5
      periodSeconds: 10
EOF

kubectl -n readiness wait --for=condition=Ready pod/pod6 --timeout=120s
```

## Question 7
**Question:** Search for the e-commerce Pod (annotation mentioning `my-happy-shop`) in Namespace `pod-move-source` and move it to `pod-move-target`.

**Answer:**
```bash
POD_NAME=$(
  kubectl -n pod-move-source get pod -o json \
    | jq -r '.items[] | select(.metadata.annotations.description | test("my-happy-shop")) | .metadata.name'
)

kubectl -n pod-move-source get pod "${POD_NAME}" -o json \
  | jq '
      del(
        .metadata.resourceVersion,
        .metadata.uid,
        .metadata.creationTimestamp,
        .metadata.managedFields,
        .status
      )
      | .metadata.namespace = "pod-move-target"
    ' \
  | kubectl apply -f -

kubectl -n pod-move-source delete pod "${POD_NAME}" --ignore-not-found
```

## Question 8
**Question:** There is an existing Deployment `api-new-c32` in `rollout` with a broken revision. Check the rollout history, identify a working revision, and rollback so the Deployment becomes Ready.

**Answer:**
```bash
kubectl -n rollout rollout history deploy/api-new-c32
kubectl -n rollout rollout undo deploy/api-new-c32
kubectl -n rollout rollout status deploy/api-new-c32
```

## Question 9
**Question:** Convert the single Pod `holy-api` in Namespace `convert-to-deploy` into a Deployment named `holy-api` with `replicas=3`. Delete the original Pod. Set container securityContext `allowPrivilegeEscalation=false` and `privileged=false`. Save the Deployment YAML to `/opt/course/exam4/q09/holy-api-deployment.yaml`.

**Answer:**
```bash
kubectl create ns convert-to-deploy || true
mkdir -p /opt/course/exam4/q09
cat > /opt/course/exam4/q09/holy-api-deployment.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: holy-api
  namespace: convert-to-deploy
spec:
  replicas: 3
  selector:
    matchLabels:
      app: holy-api
  template:
    metadata:
      labels:
        app: holy-api
    spec:
      containers:
      - name: holy
        image: nginx:1.21.6-alpine
        ports:
        - containerPort: 80
        securityContext:
          allowPrivilegeEscalation: false
          privileged: false
EOF

kubectl apply -f /opt/course/exam4/q09/holy-api-deployment.yaml
kubectl -n convert-to-deploy delete pod holy-api --ignore-not-found
```

## Question 10
**Question:** Create a ClusterIP Service `project-plt-6cc-svc` in `services-curl` exposing Pod `project-plt-6cc-api` (image `nginx:1.17.3-alpine`, label `project=plt-6cc-api`) using port mapping `3333:80`. Use a temporary Pod to curl the Service and write the response to `/opt/course/exam4/q10/service_test.html` and the app logs to `/opt/course/exam4/q10/service_test.log`.

**Answer:**
```bash
kubectl create ns services-curl || true
kubectl -n services-curl run project-plt-6cc-api --image=nginx:1.17.3-alpine --labels=project=plt-6cc-api --port=80 --restart=Never --expose=false --dry-run=client -o yaml | kubectl apply -f -
kubectl -n services-curl expose pod project-plt-6cc-api --name=project-plt-6cc-svc --type=ClusterIP --port=3333 --target-port=80

mkdir -p /opt/course/exam4/q10
kubectl -n services-curl wait --for=condition=Ready pod/project-plt-6cc-api --timeout=120s
kubectl -n services-curl run curl-tmp --image=curlimages/curl:8.10.1 --restart=Never --command -- sleep 300
kubectl -n services-curl wait --for=condition=Ready pod/curl-tmp --timeout=120s
kubectl -n services-curl exec curl-tmp -- curl -fsS --retry 30 --retry-all-errors --retry-delay 2 http://project-plt-6cc-svc.services-curl.svc.cluster.local:3333 > /opt/course/exam4/q10/service_test.html
kubectl -n services-curl logs pod/project-plt-6cc-api > /opt/course/exam4/q10/service_test.log
kubectl -n services-curl delete pod curl-tmp --ignore-not-found
```

## Question 11
**Question:** There are files to build a container image located at `/opt/course/exam4/q11/image`. The container runs a Golang application that outputs to stdout. Perform the following tasks:
Notes:
- Do not use `sudo`. Use Docker without elevated privileges.
1. Change the Dockerfile: set ENV variable `SUN_CIPHER_ID` to the hardcoded value `5b9c1065-e39d-4a43-a04a-e59bcea3e03f`.
2. Build with Docker and tag/push `localhost:5000/sun-cipher:v1-docker`.
3. Run a detached container named `sun-cipher` from `localhost:5000/sun-cipher:v1-docker` so it keeps running.
4. Capture logs to `/opt/course/exam4/q11/logs`.

**Answer:**
```bash
mkdir -p /opt/course/exam4/q11/image /opt/course/exam4/q11
cat > /opt/course/exam4/q11/image/Dockerfile <<'EOF'
FROM golang:1.21-alpine as build
WORKDIR /src
COPY . .
RUN go build -o /out/app ./ 

FROM alpine:3.18
ENV SUN_CIPHER_ID=5b9c1065-e39d-4a43-a04a-e59bcea3e03f
COPY --from=build /out/app /app
CMD ["/app"]
EOF
cat > /opt/course/exam4/q11/image/main.go <<'EOF'
package main
import (
  "fmt"
  "os"
  "time"
)
func main(){
  id := os.Getenv("SUN_CIPHER_ID")
  for { fmt.Printf("SUN_CIPHER_ID=%s\n", id); time.Sleep(2*time.Second) }
}
EOF
# Update Dockerfile (Step 1)
sed -i 's/^ENV SUN_CIPHER_ID=.*/ENV SUN_CIPHER_ID=5b9c1065-e39d-4a43-a04a-e59bcea3e03f/' /opt/course/exam4/q11/image/Dockerfile

# Build and push with Docker (Step 2)
cd /opt/course/exam4/q11/image
docker build -t localhost:5000/sun-cipher:v1-docker .
docker push localhost:5000/sun-cipher:v1-docker

# Run container (Step 3)
docker rm -f sun-cipher >/dev/null 2>&1 || true
docker run -d --name sun-cipher localhost:5000/sun-cipher:v1-docker

# Capture logs (Step 4)
docker logs sun-cipher > /opt/course/exam4/q11/logs
```

## Question 12
**Question:** Create a new PersistentVolume named `earth-project-earthflower-pv`. It must have capacity `2Gi`, accessMode `ReadWriteOnce`, use `hostPath` `/Volumes/Data` with `type: DirectoryOrCreate`, and must not define a `storageClassName`. Next, in Namespace `storage-hostpath`, create a PersistentVolumeClaim named `earth-project-earthflower-pvc` requesting `2Gi` storage with accessMode `ReadWriteOnce`, and explicitly set `storageClassName: ""` so no default StorageClass is assigned. Ensure the PVC binds to the PV. Finally, in Namespace `storage-hostpath`, create a Deployment named `project-earthflower` whose Pods use image `httpd:2.4.41-alpine` and mount the claim at `/tmp/project-data`.

**Answer:**
```bash
kubectl create ns storage-hostpath || true
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: earth-project-earthflower-pv
spec:
  capacity:
    storage: 2Gi
  accessModes: ["ReadWriteOnce"]
  hostPath:
    path: /Volumes/Data
    type: DirectoryOrCreate
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: earth-project-earthflower-pvc
  namespace: storage-hostpath
spec:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 2Gi
  storageClassName: ""
EOF
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: project-earthflower
  namespace: storage-hostpath
spec:
  replicas: 1
  selector:
    matchLabels: {app: earthflower}
  template:
    metadata:
      labels: {app: earthflower}
    spec:
      containers:
      - name: httpd
        image: httpd:2.4.41-alpine
        volumeMounts:
        - name: data
          mountPath: /tmp/project-data
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: earth-project-earthflower-pvc
EOF

kubectl -n storage-hostpath wait \
  --for=jsonpath='{.status.phase}'=Bound \
  pvc/earth-project-earthflower-pvc \
  --timeout=120s
```

## Question 13
**Question:** Create StorageClass `moon-retain` (provisioner `moon-retainer`, reclaimPolicy `Retain`). Create PVC `moon-pvc-126` (3Gi, RWO, uses `moon-retain`) in `pvc-pending`. Since the provisioner does not exist, PVC should stay Pending. Write the PVC event message to `/opt/course/exam4/q13/pvc-126-reason`.

**Answer:**
```bash
kubectl create ns pvc-pending || true
mkdir -p /opt/course/exam4/q13
cat <<'EOF' | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: moon-retain
provisioner: moon-retainer
reclaimPolicy: Retain
volumeBindingMode: Immediate
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: moon-pvc-126
  namespace: pvc-pending
spec:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 3Gi
  storageClassName: moon-retain
EOF
kubectl -n pvc-pending describe pvc moon-pvc-126 | sed -n '/Events/,$p' > /opt/course/exam4/q13/pvc-126-reason
```

## Question 14
**Question:** In Namespace `secrets-cm`, create Secret `secret1` (user=`test`, pass=`pwd`) and make it available in Pod `secret-handler` as env vars `SECRET1_USER` and `SECRET1_PASS`. Also create ConfigMap `configmap1` and mount it at `/tmp/configmap1` in the same Pod. Save updated YAML to `/opt/course/exam4/q14/secret-handler-new.yaml`.

**Answer:**
```bash
kubectl create ns secrets-cm || true
kubectl -n secrets-cm create secret generic secret1 \
  --from-literal=user=test \
  --from-literal=pass=pwd \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n secrets-cm create configmap configmap1 \
  --from-literal=example=ok \
  --dry-run=client -o yaml | kubectl apply -f -

mkdir -p /opt/course/exam4/q14
cat > /opt/course/exam4/q14/secret-handler-new.yaml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: secret-handler
  namespace: secrets-cm
spec:
  containers:
  - name: app
    image: nginx:1.21.6-alpine
    env:
    - name: SECRET1_USER
      valueFrom:
        secretKeyRef:
          name: secret1
          key: user
    - name: SECRET1_PASS
      valueFrom:
        secretKeyRef:
          name: secret1
          key: pass
    volumeMounts:
    - name: configmap1
      mountPath: /tmp/configmap1
  volumes:
  - name: configmap1
    configMap:
      name: configmap1
EOF

kubectl -n secrets-cm delete pod secret-handler --ignore-not-found
kubectl -n secrets-cm wait --for=delete pod/secret-handler --timeout=120s || true
kubectl apply -f /opt/course/exam4/q14/secret-handler-new.yaml
kubectl -n secrets-cm wait --for=condition=Ready pod/secret-handler --timeout=120s
```

## Question 15
**Question:** For Deployment `web-moon` in `configmap-web`, create ConfigMap `configmap-web-moon-html` whose data contains key `index.html` with content from `/opt/course/exam4/q15/web-moon.html`. Save the ConfigMap definition to `/opt/course/exam4/q15/configmap.yaml`.

**Answer:**
```bash
kubectl create ns configmap-web || true
mkdir -p /opt/course/exam4/q15
kubectl -n configmap-web create configmap configmap-web-moon-html \
  --from-file=index.html=/opt/course/exam4/q15/web-moon.html \
  --dry-run=client -o yaml \
  > /opt/course/exam4/q15/configmap.yaml
kubectl apply -f /opt/course/exam4/q15/configmap.yaml
```

## Question 16
**Question:** Add a sidecar `logger-con` (image `busybox:1.31.0`) to Deployment `cleaner` in `sidecar-logging` reading the same volume and executing `tail -f /var/log/cleaner/cleaner.log`. Save updated Deployment to `/opt/course/exam4/q16/cleaner-new.yaml` and ensure Deployment is running.

**Answer:**
```bash
kubectl create ns sidecar-logging || true
mkdir -p /opt/course/exam4/q16
cat > /opt/course/exam4/q16/cleaner-new.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cleaner
  namespace: sidecar-logging
spec:
  replicas: 1
  selector:
    matchLabels: {app: cleaner}
  template:
    metadata:
      labels: {app: cleaner}
    spec:
      containers:
      - name: cleaner-con
        image: busybox:1.31.0
        command: ["/bin/sh","-c","mkdir -p /var/log/cleaner; while true; do date >> /var/log/cleaner/cleaner.log; sleep 2; done"]
        volumeMounts:
        - name: logs
          mountPath: /var/log/cleaner
      - name: logger-con
        image: busybox:1.31.0
        command: ["tail","-f","/var/log/cleaner/cleaner.log"]
        volumeMounts:
        - name: logs
          mountPath: /var/log/cleaner
      volumes:
      - name: logs
        emptyDir: {}
EOF

kubectl apply -f /opt/course/exam4/q16/cleaner-new.yaml
```

## Question 17
**Question:** Add an InitContainer `init-con` (image `busybox:1.31.0`) to Deployment defined at `/opt/course/exam4/q17/test-init-container.yaml` that writes `index.html` with content `check this out!` into the shared volume. Save to `/opt/course/exam4/q17/test-init-container-new.yaml` and verify via curl.

**Answer:**
```bash
mkdir -p /opt/course/exam4/q17
cat > /opt/course/exam4/q17/test-init-container-new.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-init-container
  namespace: init-container
spec:
  replicas: 1
  selector:
    matchLabels: {app: init-web}
  template:
    metadata:
      labels: {app: init-web}
    spec:
      initContainers:
      - name: init-con
        image: busybox:1.31.0
        command: ["/bin/sh","-c","echo check this out! > /usr/share/nginx/html/index.html"]
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      containers:
      - name: web
        image: nginx:1.17.3-alpine
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        emptyDir: {}
EOF

kubectl apply -f /opt/course/exam4/q17/test-init-container-new.yaml
kubectl -n init-container rollout status deploy/test-init-container --timeout=120s
POD=$(kubectl -n init-container get pod -l app=init-web -o jsonpath='{.items[0].metadata.name}')
kubectl -n init-container exec "$POD" -- wget -qO- http://localhost | grep -F 'check this out!'
```

## Question 18
**Question:** Fix the misconfiguration in Namespace `svc-fix-endpoints` where Service `manager-api-svc` should expose Deployment `manager-api-deployment` but has no endpoints. After fixing selector/ports, the Service should have endpoints.

**Answer:**
```bash
# Fix the service by updating selector and targetPort
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: manager-api-svc
  namespace: svc-fix-endpoints
spec:
  selector:
    app: manager-api
  ports:
  - port: 4444
    targetPort: 4444
    protocol: TCP
EOF

# Verify the service now has endpoints
kubectl -n svc-fix-endpoints get endpoints manager-api-svc
```

## Question 19
**Question:** In Namespace `nodeport-30100`, change Service `jupiter-crew-svc` from `ClusterIP` to `NodePort` and set `nodePort=30100`. Verify reachability inside cluster (single-node clusters reachable on that node).

**Answer:**
```bash
# Update the service to NodePort type with nodePort 30100
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: jupiter-crew-svc
  namespace: nodeport-30100
spec:
  type: NodePort
  selector:
    app: jupiter
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30100
    protocol: TCP
EOF

# Verify the service is reachable via a node IP from the jumphost
NODE_IP=$(kubectl get nodes -o wide --no-headers | awk 'NR==1{print $6}')
curl -fsS "http://${NODE_IP}:30100" >/dev/null \
  || ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null candidate@k8s-api-server "curl -fsS http://127.0.0.1:30100 >/dev/null"
```

## Preview P1 (Q20)
**Question:** Add a liveness probe (TCP 80, initialDelay=10s, period=15s) to Deployment `project-23-api` in `p1-liveness`. Save to `/opt/course/exam4/p1/project-23-api-new.yaml` and apply.

**Answer:**
```bash
mkdir -p /opt/course/exam4/p1
cat > /opt/course/exam4/p1/project-23-api-new.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: project-23-api
  namespace: p1-liveness
spec:
  replicas: 1
  selector:
    matchLabels: {app: p23}
  template:
    metadata:
      labels: {app: p23}
    spec:
      containers:
      - name: api
        image: nginx:1.21.6-alpine
        ports:
        - containerPort: 80
        livenessProbe:
          tcpSocket:
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 15
EOF

kubectl apply -f /opt/course/exam4/p1/project-23-api-new.yaml
```

## Preview P2 (Q21)
**Question:** Create Deployment `sunny` with `replicas=4` using image `nginx:1.17.3-alpine` in `p2-deploy-svc` and set `serviceAccountName=sa-sun-deploy`. Expose it via ClusterIP Service `sun-srv` on port 9999. Write a kubectl command to `/opt/course/exam4/p2/sunny_status_command.sh` that checks all Pods are running.

**Answer:**
```bash
kubectl create ns p2-deploy-svc || true
kubectl -n p2-deploy-svc create sa sa-sun-deploy || true
mkdir -p /opt/course/exam4/p2

cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sunny
  namespace: p2-deploy-svc
spec:
  replicas: 4
  selector:
    matchLabels:
      app: sunny
  template:
    metadata:
      labels:
        app: sunny
    spec:
      serviceAccountName: sa-sun-deploy
      containers:
      - name: nginx
        image: nginx:1.17.3-alpine
        ports:
        - containerPort: 80
EOF

kubectl -n p2-deploy-svc expose deploy sunny --name=sun-srv --type=ClusterIP --port=9999 --target-port=80

mkdir -p /opt/course/exam4/p2
cat > /opt/course/exam4/p2/sunny_status_command.sh <<'EOF'
#!/usr/bin/env bash
kubectl -n p2-deploy-svc get pods -l app=sunny --no-headers
EOF
chmod +x /opt/course/exam4/p2/sunny_status_command.sh
```

## Preview P3 (Q22)
**Question:** Fix the readinessProbe port in Deployment `earth-3cc-web` in `p3-readiness` so that Pods become ready and Service `earth-3cc-web-svc` reflects a ready Deployment state. Write a short description of the issue to `/opt/course/exam4/p3/ticket-description.txt`.

**Answer:**
```bash
mkdir -p /opt/course/exam4/p3
# Fix only the broken readiness probe port on the existing Deployment
kubectl -n p3-readiness patch deployment earth-3cc-web \
  --type='json' \
  -p='[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/port","value":80}]'

# Write ticket description
echo "The readiness probe was configured to use port 8081, but the container only exposes port 80. Fixed the readinessProbe port to match the containerPort (80)." > /opt/course/exam4/p3/ticket-description.txt

# Verify pods become ready
kubectl -n p3-readiness rollout status deploy/earth-3cc-web --timeout=120s
```
