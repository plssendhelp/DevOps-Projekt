#!/bin/bash

# Update package list
sudo apt update -y

# Install all the necessary dependencies
sudo apt install -y mysql-server python3-pip python3-venv wget

# Update the database
sudo mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS demo_app;
CREATE USER IF NOT EXISTS 'app-user'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON demo_app.* TO 'app-user'@'localhost';
FLUSH PRIVILEGES;
EOF

# Install and init python dependencies
python3 -m venv ../demo-app/venv
source ../demo-app/venv/bin/activate
pip3 install -r ../demo-app/requirements.txt
python3 ../demo-app/app.py

