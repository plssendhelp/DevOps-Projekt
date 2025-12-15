# Introduction
This repository contains our homework where we automate the deployment of a complete application stack using Vagrant and cloud-init. The stack solution includes:

- Python Flask web app
- Nginx
- MySQL database
- Redis

The goal of this project was to demonstrate provision automation in two different ways with vagrant (for local development) and cloud-init (for provisioning on instance boot). With that in mind the system should deplay reasonably quickly but most importantly it should be reproducible! Below are the tutorials for the two solutions.

# Vagrant
To run the Vagrant solution we must first install it to our device. 

> [!NOTE]
> this will depend on your device so we suggest following their tutorial [here](https://developer.hashicorp.com/vagrant/tutorials/get-started/install).

Then you must obtain the folder where our solution lies. That can be easily done with git if you do not have it installed yet you can easily do with your package manager or by following their tutorial [here](https://git-scm.com/install). We will be using git:

```sh
$ git clone https://github.com/plssendhelp/DevOps-Projekt.git
```

Then we need to move to a correct directory:

```sh
$ cd DevOps-Projekt/1.1-vagrant
```

And finally run our solution simply by doing:

```sh
$ vagrant up
```

> [!NOTE]
> You should change `email` and `domain` variables inside `install-dependencies.sh` if you wish to run this script seriously.

[![Vagrant up output](https://img.youtube.com/vi/JgrH1SPVR9k/0.jpg)](https://youtu.be/JgrH1SPVR9k)

[![App preview](https://img.youtube.com/vi/nzVMxgF9prI/0.jpg)](https://youtu.be/nzVMxgF9prI)

You can access our solution at http://devops-vm-28.lrk.si:8080

# cloud-init
This project demonstrates an automated deployment of a simple Python web application
using **Incus** containers, **cloud-init** provisioning, and **Nginx reverse proxy** on the host.
The result is a fully working demo application accessible from the public domain:
**https://devops-vm-39.lrk.si**

How provisioning works:
When creating the container:

```
incus launch images:ubuntu/22.04/cloud cloud-demo \
  -c cloud-init.user-data="$(cat cloud-config.yaml)"
```
Cloud-init performs:
### Package installation
- python3, pip
- mysql-server
- nginx
- redis-server

### Creates application directory
`/opt/devops-demo/demo-app/`

### Writes files (app.py, requirements.txt, unit service)

### Installs Python dependencies
```
pip install -r /opt/devops-demo/demo-app/requirements.txt
```

### Initializes database
- creates DB `demo_app`
- creates MySQL user
- initializes table `counter`

### Starts systemd service
```
systemctl enable flaskapp
systemctl start flaskapp
```
Nginx reverse proxy (host → container)
File: `/etc/nginx/sites-available/devops-demo`

```
server {
    listen 80;
    server_name devops-vm-39.lrk.si;

    location / {
        proxy_pass http://10.168.179.250:8080;  # container private IP
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```
Enable site:

```
sudo ln -s /etc/nginx/sites-available/devops-demo /etc/nginx/sites-enabled/
sudo systemctl restart nginx
```

## HTTPS with Let’s Encrypt
```
sudo certbot --nginx -d devops-vm-39.lrk.si
```

you can access the solution with: http://devops-vm-39.lrk.si/

