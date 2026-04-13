# CKA Mock Exam 01 — Solutions

## Q1: ConfigMap Mount Fix

```bash
kubectl create configmap app-config -n production \
  --from-literal=config.yaml="database_host: postgres.production.svc.cluster.local"

# Get current pod YAML, add volume + mount
kubectl get pod app-frontend -n production -o yaml > /tmp/app-frontend.yaml
# Edit to add:
# spec.volumes: [{name: config, configMap: {name: app-config, items: [{key: config.yaml, path: config.yaml}]}}]
# spec.containers[0].volumeMounts: [{name: config, mountPath: /etc/app, readOnly: true}]
kubectl replace --force -f /tmp/app-frontend.yaml
```

## Q2: RBAC

```bash
kubectl create role dev-role -n staging --verb=get,list,watch --resource=pods,deployments
kubectl create rolebinding dev-binding -n staging --role=dev-role --user=dev-user
kubectl auth can-i list pods -n staging --as=dev-user  # should return: yes
```

## Q3: Node Drain

```bash
kubectl cordon k3d-cluster-agent-1
kubectl drain k3d-cluster-agent-1 --ignore-daemonsets --delete-emptydir-data
kubectl get nodes  # k3d-cluster-agent-1: SchedulingDisabled
```

## Q4: PV + PVC + Deployment Mount

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: db-pv
spec:
  capacity:
    storage: 5Gi
  accessModes: [ReadWriteOnce]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: fast-ssd
  hostPath:
    path: /data/db
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: db-pvc
  namespace: databases
spec:
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 5Gi
  storageClassName: fast-ssd
```

```bash
kubectl set env deployment/db-app -n databases PLACEHOLDER=x  # trigger redeploy
kubectl patch deployment db-app -n databases --type=json -p='[
  {"op":"add","path":"/spec/template/spec/volumes","value":[{"name":"db-data","persistentVolumeClaim":{"claimName":"db-pvc"}}]},
  {"op":"add","path":"/spec/template/spec/containers/0/volumeMounts","value":[{"name":"db-data","mountPath":"/data"}]}
]'
```

## Q5: NetworkPolicies

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-policy
  namespace: shop
spec:
  podSelector:
    matchLabels:
      tier: frontend
  policyTypes: [Ingress]
  ingress:
  - ports:
    - port: 80
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
  namespace: shop
spec:
  podSelector:
    matchLabels:
      tier: backend
  policyTypes: [Ingress]
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: frontend
    ports:
    - port: 3000
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-policy
  namespace: shop
spec:
  podSelector:
    matchLabels:
      tier: database
  policyTypes: [Ingress]
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: backend
    ports:
    - port: 5432
```

## Q6: Helm Install

```bash
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring-stack prometheus-community/kube-prometheus-stack \
  -n monitoring \
  --set replicaCount=1 \
  --set prometheusOperator.enabled=false
```

## Q7: PriorityClass

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 100000
globalDefault: false
preemptionPolicy: PreemptLowerPriority
description: High priority class for critical practice workload
---
apiVersion: v1
kind: Pod
metadata:
  name: important-nginx
  namespace: default
spec:
  priorityClassName: high-priority
  containers:
  - name: nginx
    image: nginx:1.27
```

## Q8: HPA

```bash
kubectl autoscale deployment web-app -n production \
  --name=web-app-hpa --min=2 --max=10 --cpu-percent=70
```

## Q9: Ingress with TLS

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  namespace: default
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - api.example.com
    secretName: api-tls-cert
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api
            port:
              number: 80
```

## Q10: Fix broken Deployment

```bash
kubectl get pods -n troubleshooting
kubectl describe deployment broken-web -n troubleshooting
kubectl set image deployment/broken-web web=nginx:1.27 -n troubleshooting
kubectl rollout status deployment/broken-web -n troubleshooting
```

## Q11: StatefulSet + Headless Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: database-cluster
  namespace: databases
spec:
  clusterIP: None
  selector:
    app: database-cluster
  ports:
  - port: 5432
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: database-cluster
  namespace: databases
spec:
  serviceName: database-cluster
  replicas: 3
  selector:
    matchLabels:
      app: database-cluster
  template:
    metadata:
      labels:
        app: database-cluster
    spec:
      containers:
      - name: postgres
        image: postgres:15
        env:
        - name: POSTGRES_PASSWORD
          value: "password"
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ReadWriteOnce]
      storageClassName: standard
      resources:
        requests:
          storage: 10Gi
```

## Q12: ResourceQuota + LimitRange

```bash
kubectl create namespace test
kubectl apply -f - <<EOF
apiVersion: v1
kind: ResourceQuota
metadata:
  name: test-quota
  namespace: test
spec:
  hard:
    requests.cpu: "4"
    limits.cpu: "8"
    requests.memory: 8Gi
    limits.memory: 16Gi
    pods: "20"
---
apiVersion: v1
kind: LimitRange
metadata:
  name: test-limits
  namespace: test
spec:
  limits:
  - type: Container
    defaultRequest:
      cpu: 100m
      memory: 128Mi
EOF
```

## Q13: Pod Security Standards

```bash
kubectl create namespace restricted
kubectl label namespace restricted \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/audit=baseline

# Compliant pod (no root, no privilege escalation, drop ALL caps)
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
  namespace: restricted
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

## Q14: Multi-container Sidecar Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-logger
spec:
  initContainers:
  - name: log-streamer
    image: busybox:1.36
    restartPolicy: Always
    command: ["sh", "-c", "tail -f /logs/access.log 2>/dev/null || sleep 3600"]
    volumeMounts:
    - name: logs
      mountPath: /logs
  containers:
  - name: nginx
    image: nginx:1.27
    volumeMounts:
    - name: logs
      mountPath: /var/log/nginx
  volumes:
  - name: logs
    emptyDir: {}
```

## Q15: Namespace Resource Backup

```bash
kubectl get all,configmap -n backup-task -o yaml > /opt/backup-task.yaml
grep -n "backup-app\\|app-settings" /opt/backup-task.yaml
```
