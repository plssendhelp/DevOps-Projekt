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
TODO!

