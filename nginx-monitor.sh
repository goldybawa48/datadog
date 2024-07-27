#!/bin/bash

sudo apt-get update

sudo apt install curl -y 

sudo apt install nginx -y

sudo systemctl start nginx

sudo systemctl enable nginx

DD_API_KEY=your-datadog-id DD_SITE="us5.datadoghq.com" bash -c "$(curl -L https://install.datadoghq.com/scripts/install_script_agent7.sh)"


sudo bash -c 'cat <<EOL >> /etc/nginx/conf.d/status.conf

server {
  listen 81;
  server_name localhost;

  access_log off;
  allow 127.0.0.1;
  deny all;

  location /nginx_status {
    # Choose your status module

    # freely available with open source NGINX
    stub_status;

    # for open source NGINX < version 1.7.5
    # stub_status on;

    # available only with NGINX Plus
    # status;

    # ensures the version information can be retrieved
    server_tokens on;
  }
}

EOL'


sudo bash -c 'cat <<EOL >> /etc/datadog-agent/conf.d/nginx.d/conf.yaml

logs:
  - type: file
    path: /var/log/nginx/access.log
    service: nginx
    source: nginx

  - type: file
    path: /var/log/nginx/error.log
    service: nginx
    source: nginx

init_config:

instances:
  - nginx_status_url: http://localhost:81/nginx_status
    tags:
      - instance:my_nginx

    
EOL'

sudo bash -c 'cat <<EOL >> /etc/datadog-agent/datadog.yaml
logs_enabled: true
EOL'

sudo chmod 777 -R /var/log/nginx

sudo systemctl reload nginx
sudo systemctl restart nginx
sudo service datadog-agent restart

