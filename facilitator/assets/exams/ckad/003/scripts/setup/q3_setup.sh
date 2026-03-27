#!/bin/bash
kubectl create ns q3-api
cat << 'EOF' > /tmp/old-cronjob.yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: old-cron
spec:
  schedule: "0 0 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            command: ["echo", "hello"]
          restartPolicy: OnFailure
EOF
