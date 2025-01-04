#!/bin/bash

echo "Laravel Project Setup Script"
echo "-----------------------------"

# Input variables
read -p "Enter project name: " PROJECT_NAME
read -p "Enter PHP version (e.g., 8.2 or 8.3): " PHP_VERSION
read -p "Enter GitHub repository URL (HTTPS): " GITHUB_URL
read -p "Enter MySQL root password: " MYSQL_ROOT_PASS
read -p "Enter database name: " DB_NAME
read -p "Enter database username: " DB_USER
read -p "Enter database user password: " DB_PASS
read -p "Enter domain: " DOMAIN

# Update and install required packages
echo "Updating system and installing required packages..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y nginx mysql-server php${PHP_VERSION} php${PHP_VERSION}-fpm php${PHP_VERSION}-cli php${PHP_VERSION}-mysql php${PHP_VERSION}-xml php${PHP_VERSION}-mbstring php${PHP_VERSION}-zip git unzip curl nodejs npm composer

# Configure MySQL
echo "Configuring MySQL..."
sudo mysql -e "CREATE DATABASE ${DB_NAME};"
sudo mysql -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Clone the project from GitHub
echo "Cloning project from GitHub..."
sudo mkdir -p /var/www/${PROJECT_NAME}
sudo git clone ${GITHUB_URL} /var/www/${PROJECT_NAME}

# Set permissions
echo "Setting permissions..."
sudo chown -R www-data:www-data /var/www/${PROJECT_NAME}
sudo chmod -R 775 /var/www/${PROJECT_NAME}

# Configure environment
echo "Configuring .env file..."
sudo cp /var/www/${PROJECT_NAME}/.env.example /var/www/${PROJECT_NAME}/.env
sudo sed -i "s/DB_DATABASE=.*/DB_DATABASE=${DB_NAME}/" /var/www/${PROJECT_NAME}/.env
sudo sed -i "s/DB_USERNAME=.*/DB_USERNAME=${DB_USER}/" /var/www/${PROJECT_NAME}/.env
sudo sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=${DB_PASS}/" /var/www/${PROJECT_NAME}/.env

# Install PHP dependencies
echo "Installing PHP dependencies..."
cd /var/www/${PROJECT_NAME}
sudo composer install --no-dev --optimize-autoloader
sudo php artisan key:generate

# Set up Nginx
echo "Configuring Nginx..."
NGINX_CONF="/etc/nginx/sites-available/${PROJECT_NAME}"
sudo cat > ${NGINX_CONF} <<EOL
server {
    listen 80;
    server_name ${DOMAIN};

    root /var/www/${PROJECT_NAME}/public;

    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php${PHP_VERSION}-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOL

# Enable site and restart Nginx
sudo ln -s ${NGINX_CONF} /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Set up Node.js dependencies
echo "Installing Node.js dependencies..."
npm install && npm run build

# Final message
echo "Laravel project ${PROJECT_NAME} has been successfully set up!"
echo "Access it via ${DOMAIN}"
