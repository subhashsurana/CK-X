# CK-X Simulator: Development Setup Guide

This document provides step-by-step instructions for setting up and running the CK-X Simulator locally for development purposes.

## Prerequisites

### System Requirements
- **Operating System**: Linux, macOS, or Windows 10/11 with WSL2
- **CPU**: 4+ cores recommended (minimum 2 cores)
- **RAM**: 8GB minimum, 16GB recommended
- **Storage**: 20GB free space

### Required Software
- **Docker**: v20.10.0 or newer
- **Docker Compose**: v2.0.0 or newer

## Installation Steps

### 1. Clone the Repository

```bash
git clone git@github.com:subhashsurana/CK-X.git
cd CK-X
```

If you are working on a new lab or a substantial content change, create a feature branch first:

```bash
git switch -c feat-my-change
```

### 2. Configure the Environment

Review the `compose.yaml` file to understand the service configuration. Key services include:

- **remote-desktop**: VNC server (Ubuntu)
- **webapp**: Web Application frontend
- **nginx**: Reverse proxy (only service exposed to users)
- **jumphost**: SSH access host
- **remote-terminal**: Remote terminal service
- **k8s-api-server**: KIND Kubernetes cluster
- **redis**: Redis database for Facilitator
- **facilitator**: Backend service

### 3. Start the Services

```bash
# Build and start all services in the background
docker compose up --build -d
```

This command builds the local images from the current checkout and starts the full simulator stack.

## Accessing the Application

### 1. Web Interface

Once all services are running, access the web interface via Nginx:

```
http://localhost:30080
```

The Facilitator API is also exposed for debugging at:

```
http://localhost:3001
```

### 2. VNC Remote Desktop

The VNC server is not directly exposed outside the container network. To access it:

1. The web interface proxies VNC connections through Nginx
2. Default VNC password: `bakku-the-wizard` (configured in compose.yaml)
3. VNC resolution: 1280x800

### 3. SSH Access

SSH access is provided through the jumphost service:

- **Hostname**: ckad9999
- **Username**: candidate
- **Password**: password (configured in compose.yaml)

The SSH service is not directly exposed outside the container network and is accessed through the webapp.

## Service Details

### 1. Remote Desktop (VNC)

```yaml
# From compose.yaml
remote-desktop:
  image: nishanb/ck-x-simulator-remote-desktop:latest
  hostname: terminal
  expose:
    - "5901"  # VNC port (internal only)
    - "6901"  # Web VNC port (internal only)
  environment:
    - VNC_PW=bakku-the-wizard
    - VNC_PASSWORD=bakku-the-wizard
    - VNC_VIEW_ONLY=false
    - VNC_RESOLUTION=1280x800
```

The remote desktop provides a graphical interface for the exam environment.

### 2. Web Application

```yaml
# From compose.yaml
webapp:
  image: nishanb/ck-x-simulator-webapp:latest
  expose:
    - "3000"  # Only exposed to internal network
  environment:
    - VNC_SERVICE_HOST=remote-desktop
    - VNC_SERVICE_PORT=6901
    - VNC_PASSWORD=bakku-the-wizard
    - SSH_HOST=remote-terminal
    - SSH_PORT=22
    - SSH_USER=candidate
    - SSH_PASSWORD=password
```

The web application serves as the frontend interface for the simulator.

### 3. Nginx (Reverse Proxy)

```yaml
# From compose.yaml
nginx:
  image: nishanb/ck-x-simulator-nginx:latest
  ports:
    - "30080:80"  # Expose Nginx on port 30080
```

Nginx is the only service directly exposed to users and handles routing to internal services.

### 4. Kubernetes Cluster

```yaml
# From compose.yaml
k8s-api-server:
  image: nishanb/ck-x-simulator-cluster:latest
  container_name: kind-cluster
  hostname: k8s-api-server
  privileged: true  # Required for running containers inside KIND
  expose:
    - "6443:6443" 
    - "22"
  volumes:
    - kube-config:/home/candidate/.kube  # Shared volume for Kubernetes config
```

The Kubernetes cluster runs in a KIND container with shared kube-config volume.

### 5. Facilitator Service

```yaml
# From compose.yaml
facilitator:
  image: nishanb/ck-x-simulator-facilitator:latest
  hostname: facilitator
  expose:
    - "3000"
  ports:
    - "3001:3000"
  environment:
    - PORT=3000
    - NODE_ENV=prod
    - SSH_HOST=jumphost
    - SSH_PORT=22
    - SSH_USERNAME=candidate
    - LOG_LEVEL=info
    - REDIS_HOST=redis
    - REDIS_PORT=6379
```

The facilitator service handles backend operations and communicates with the Kubernetes cluster.

## Development Workflow

### 0. Lab Author Workflow

For assessment and validation work such as `facilitator/assets/exams/...`:

1. Edit the lab files locally.
2. Rebuild and restart the `facilitator` service so the updated exam assets are copied into the container and repackaged into `assets.tar.gz`.
3. Open the simulator at `http://localhost:30080`, start the target lab, and run through the scenario.
4. Review container logs if setup or evaluation fails.

The Facilitator container packages exam `scripts/` into `assets.tar.gz` during startup, so lab asset changes are not picked up until that container is rebuilt or restarted from a fresh image.

### 1. Modifying Services

To modify a service, edit its corresponding directory and then rebuild:

```bash
# Edit files in the respective service directory
# Then rebuild and restart the service
docker compose up --build -d <service-name>
```

Examples:

```bash
# Rebuild only the facilitator after changing assessments, answers, or validation scripts
docker compose up --build -d facilitator

# Rebuild the whole stack after wider application changes
docker compose up --build -d
```

### 2. Validating Lab Changes Locally

Typical commands while iterating on a lab:

```bash
# Check service health and startup state
docker compose ps

# Follow facilitator logs while the lab is preparing or grading
docker compose logs -f facilitator

# Follow jumphost logs to see exam setup execution
docker compose logs -f jumphost

# Open a shell in the facilitator container
docker compose exec facilitator sh
```

Suggested smoke test for a new or updated lab:

1. Start the stack with `docker compose up --build -d`.
2. Open `http://localhost:30080`.
3. Start the target lab from the UI and wait for it to reach `READY`.
4. Solve or partially solve the target questions.
5. Trigger evaluation from the UI.
6. Confirm the expected validation steps pass or fail.

### 3. Inspecting Logs

```bash
# View logs for all services
docker compose logs

# View logs for a specific service
docker compose logs <service-name>

# Follow logs
docker compose logs -f <service-name>
```

### 4. Accessing Containers

```bash
# Get shell access to a container
docker compose exec <service-name> sh

# Examples:
docker compose exec webapp sh
docker compose exec facilitator sh
docker compose exec k8s-api-server sh
```

### 5. Pushing Your Branch

After validating your changes locally:

```bash
# Review only the files you intend to ship
git status
git diff

# Stage and commit the specific files you changed
git add <files>
git commit -m "feat: describe the change"

# Push the feature branch
git push -u origin feat-my-change
```

If the worktree already contains unrelated modifications, stage only the intended files instead of using `git add .`.

## Troubleshooting

### 1. Container Startup Issues

If containers fail to start, check the logs:

```bash
docker compose logs <service-name>
```

### 2. VNC Connection Issues

```bash
# Check if VNC server is running
docker compose exec remote-desktop sh -lc 'ps aux | grep vnc'

# Restart VNC service
docker compose restart remote-desktop
```

### 3. Kubernetes Cluster Issues

```bash
# Check cluster status
docker compose exec k8s-api-server kubectl cluster-info

# Restart the cluster
docker compose restart k8s-api-server
```

### 4. Resource Constraints

If your system cannot handle the resource requirements, adjust the limits in compose.yaml:

```yaml
deploy:
  resources:
    limits:
      cpus: '1'  # Reduce CPU allocation
      memory: 1G  # Reduce memory allocation
```

## Network Architecture

All services are connected through the `ckx-network` bridge network:

```yaml
networks:
  ckx-network:
    name: ckx-network
    driver: bridge
```

Services can communicate with each other using their service names as hostnames.

## Volume Management

The system uses persistent volumes for:

```yaml
volumes:
  kube-config:  # Shared volume for Kubernetes configuration
  redis-data:   # Persistent volume for Redis data
```

## Reference Links

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [KIND Documentation](https://kind.sigs.k8s.io/)
- [VNC Documentation](https://www.realvnc.com/en/connect/docs/) 
