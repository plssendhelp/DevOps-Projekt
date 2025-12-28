# Introduction
This repository contains our homework where we dockerize an application stack consisting of:

- Python Flask web app
- Nginx
- MySQL database
- Redis
- TLS configuration

# Setup
The stack is defined in `docker-compose.yml` and can be started with:
```sh
$ sudo docker compose up -d --build
```

# Details
The entire app spins up in a couple of seconds! Below is a more detailed explanation of each component.

## Application
Python Flask app with a minimal python image. We build a custom image using multi-stage Dockerfile.
`Content size: ` **79.5MB**.

## MySQL
DB initialization via env variables and persistent storage. 

## Redis
Used for in memory cache.

## Nginx
Handles TLS termination and serves ACME challenge file for certbot.


## TLS
Certificates are issues by Lets encrypt using certbot inside a container with:

```sh
$ sudo docker compose run --rm certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email tm16521@student.uni-lj.si \
    --agree-tos \
    --no-eff-email \
    -d devops-vm-28.lrk.si

```

# Deployment
The stack is deployed and publicly accessible [here](https://devops-vm-28.lrk.si)

