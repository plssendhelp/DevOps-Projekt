#!/bin/bash
set -e


# Variables
app_path="/opt/demo-app"
domain="devops-vm-28.lrk.si"
email="tm16521@student.uni-lj.si"


# Update and install all pacakages
sudo apt update -y
sudo apt install -y \
    git \
    mysql-server \
    python3-pip python3-venv \
    nginx \
    redis-server \
    certbot python3-certbot-nginx


# +------------------------------+
# |        MySQL Database        |
# +------------------------------+
# Create a database and a user if they dont exist yet
sudo mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS demo_app;
CREATE USER IF NOT EXISTS 'app-user'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON demo_app.* TO 'app-user'@'localhost';
FLUSH PRIVILEGES;
EOF


# +------------------------------+
# |          Python App          |
# +------------------------------+
# [Testing] check if the dir exists -> destory it
if [ -d ${app_path} ]; then
    echo "Removing for testing..."
    sudo rm -rf ${app_path}
fi

# Clone this repo and only get the demo-app folder
git clone https://github.com/plssendhelp/DevOps-Projekt.git
sudo cp -r DevOps-Projekt/demo-app/. ${app_path}
rm -rf DevOps-Projekt

# Make the dir owned by the current user so we can write there
sudo chown -R $USER:$USER /opt/demo-app


# Init the env and install all python dependencies
python3 -m venv /opt/demo-app/venv
"${app_path}/venv/bin/pip3" install -r "${app_path}/requirements.txt"


# [Testting] systemd service check if the file exists -> destroy it
if [ -f "/etc/systemd/system/demo-app.service" ]; then
    sudo rm -f /etc/systemd/system/demo-app.service
fi

# Create a new service for the app
sudo tee /etc/systemd/system/demo-app.service > /dev/null <<EOF
[Unit]
Description=Demo App
After=network.target mysql.service

[Service]
User=root
WorkingDirectory=${app_path}
Environment="PATH=${app_path}/venv/bin"
ExecStart=${app_path}/venv/bin/python3 ${app_path}/app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload, enable and start
sudo systemctl daemon-reload
sudo systemctl enable demo-app
sudo systemctl restart demo-app


# +------------------------------+
# |            Nginx             |
# +------------------------------+
# Remove the default site
sudo rm -f /etc/nginx/sites-enabled/default

# Create an nginx site config
sudo tee /etc/nginx/sites-available/demo-app.conf > /dev/null <<EOF
server {
    listen 80;
    server_name ${domain};

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

    }
}
EOF

# Enabling the nginx site
sudo ln -sf /etc/nginx/sites-available/demo-app.conf /etc/nginx/sites-enabled/demo-app.conf
# Check the config syntax to avoid breaking the web server
sudo nginx -t
# Reload to apply the new config
sudo systemctl restart nginx


# +------------------------------+
# |            Redis             |
# +------------------------------+
# Tell redis to integrate with systemd
sudo sed -i 's/^supervised .*/supervised systemd/' /etc/redis/redis.conf
# Enable append-only persistence so redis data is not lost on restart
sudo sed -i 's/^# appendonly no/appendonly yes/' /etc/redis/redis.conf
# Restart to apply the new config
sudo systemctl restart redis-server
# Enables redis at boot
sudo systemctl enable redis-server

# Obtain and renew a certificate for domain and let certbot auto-configure nginx
#sudo certbot --nginx --non-interactive --redirect --agree-tos \
#    -m "${email}" \
#    -d "${domain}" 


# Open ports
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw --force enable


echo "Done"
