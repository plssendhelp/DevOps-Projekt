# Kubernetes Application Stack (DevOps Homework)

## Overview

This project recreates a previously implemented Docker Compose application stack using Kubernetes.

The application is deployed on a public virtual machine and demonstrates:

- High availability
- Persistent storage
- TLS-secured public access
- Rolling updates with zero downtime
- Blue/Green deployment

The application is a simple Flask web application that uses MySQL for persistent data storage and Redis for in-memory visit counting.

---

## Application Architecture

The Kubernetes stack consists of the following application services:

1. **Flask application (app)**
   - Custom-built Docker image
   - Exposed via Kubernetes Service and Ingress
   - Scaled to multiple replicas

2. **MySQL**
   - Persistent relational database
   - Backed by a PersistentVolume

3. **Redis**
   - In-memory data store for visit counting

Ingress, cert-manager, and other system components are not counted as application services.

---

## Container Images

### Multi-stage Docker Build

The Flask application image is custom-built using a multi-stage Dockerfile:

- **Builder stage**
  - Installs Python dependencies
- **Runtime stage**
  - Uses `python:3.12-slim`
  - Contains only runtime dependencies and application code

This results in a minimal final image, following container best practices.

---

## Kubernetes Manifests

All Kubernetes resources are defined using YAML manifests and stored in the `k8s/` directory:

- Deployments
- Services
- Secrets
- PersistentVolumes and PersistentVolumeClaims
- Ingress resources
- Blue/Green deployment manifests

---

## Persistent Storage

Persistent storage is used for MySQL data via:

- PersistentVolume
- PersistentVolumeClaim

This ensures database data is preserved across Pod restarts and deployments.

---

## High Availability

High availability is achieved by:

- Running **3 replicas of the Flask application**
- Kubernetes Service load-balancing traffic across Pods
- Allowing one extra Pod during rolling updates

---

## Ingress and TLS

The application is exposed publicly using:

- NGINX Ingress Controller
- cert-manager for certificate management
- Automatically issued and rotated TLS certificates

The application is accessible via HTTPS on a public domain.

---

## Readiness and Liveness

The application does not implement a dedicated `/health` endpoint.

Stability is ensured by:
- Successful container startup
- Continuous HTTP request handling
- Kubernetes restart behavior during failures

This approach matches the simplicity of the application.

---

## Rolling Update (Zero Downtime)

The Flask application supports rolling updates without downtime.

Deployment configuration:
- `replicas: 3`
- `maxUnavailable: 0`
- `maxSurge: 1`

During an update:
- Only one Pod is replaced at a time
- Existing Pods continue serving traffic
- The application remains reachable at all times

## Blue/Green Deployment

A Blue/Green deployment strategy is implemented for the Flask application.

- **Blue version**
  - Image: `ghcr.io/surina8/devops-app:v1`
- **Green version**
  - Image: `ghcr.io/surina8/devops-app:v2`

Both versions run simultaneously in the cluster.  
Traffic routing is controlled by a Kubernetes Service selector.

## How to run
1. Deploy Kubernetes resources:
- kubectl apply -f k8s/
2. Verify pods:
- kubectl -n devops get pods
3. Access the application via Ingress (HTTPS) or using: kubectl -n devops port-forward svc/app 8080:80

## screenshoti za 0 rundown time in za greenblue deployment
Zero down time:
- <img width="991" height="428" alt="0d" src="https://github.com/user-attachments/assets/9e51d8f1-2185-455e-a0dd-fb2192ccf835" />
- <img width="986" height="314" alt="0r" src="https://github.com/user-attachments/assets/2bb69558-b3fd-4df2-a897-bff37235f256" />
GreenBlue:
- <img width="957" height="261" alt="gree" src="https://github.com/user-attachments/assets/de3fac4f-bcc6-474a-ae9a-67602440067e" />
- <img width="904" height="319" alt="blu" src="https://github.com/user-attachments/assets/9c08ed1f-4356-495f-894e-4740f1893629" />



