#!/bin/bash

sudo apt-get update

sudo apt install curl -y 

sudo apt install apache2 -y

sudo systemctl start apache2

sudo systemctl enable apache2

DD_API_KEY=your-datadog-id DD_SITE="us5.datadoghq.com" bash -c "$(curl -L https://install.datadoghq.com/scripts/install_script_agent7.sh)"


sudo bash -c 'cat <<EOL >> /etc/datadog-agent/conf.d/apache.d/conf.yaml

init_config:

instances:
  ## @param apache_status_url - string - required
  ## Status url of your Apache server.
  #
  - apache_status_url: http://localhost/server-status?auto
   
logs:
  - type: file
    path: /path/to/your/apache/access.log
    source: apache
    service: apache
    sourcecategory: http_web_access

  - type: file
    path: /path/to/your/apache/error.log
    source: apache
    service: apache
    sourcecategory: http_web_error

EOL'

sudo bash -c 'cat <<EOL >> /etc/datadog-agent/datadog.yaml
logs_enabled: true
EOL'

sudo chmod 777 -R /var/log/apache2

sudo systemctl reload apache2
sudo systemctl restart apache2
sudo service datadog-agent restart

