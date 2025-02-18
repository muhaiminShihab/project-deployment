#!/bin/bash

echo "Laravel Project Setup Script"
echo "-----------------------------"

# Function to prompt for user confirmation
confirm() {
    read -r -p "${1:-Are you ready?} [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

# Input variables
read -p "Enter project name: " PROJECT_NAME
read -p "Enter PHP version (e.g., 8.2 or 8.3): " PHP_VERSION
read -p "Enter Node version (e.g., 19.x or 20.x): " NODE_VERSION
read -p "Enter GitHub repository URL (HTTPS): " GITHUB_URL
read -p "Enter MySQL root password: " MYSQL_ROOT_PASS
read -p "Enter database name: " DB_NAME
read -p "Enter database username: " DB_USER
read -p "Enter database user password: " DB_PASS
read -p "Enter domain (muhaiminShihab.github.io): " DOMAIN

# Update and install required packages
echo "Updating system and installing required packages..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y software-properties-common curl unzip git nginx mysql-server nodejs npm certbot python3-certbot-nginx

# Add PHP repository and install PHP
echo "Installing PHP and required extensions..."
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update
sudo apt install -y php${PHP_VERSION} \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-common \
    php${PHP_VERSION}-opcache \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-imagick \
    php${PHP_VERSION}-ldap \
    composer

# Configure MySQL
echo "Configuring MySQL..."
sudo mysql -u root -p"${MYSQL_ROOT_PASS}" -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
sudo mysql -u root -p"${MYSQL_ROOT_PASS}" -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
sudo mysql -u root -p"${MYSQL_ROOT_PASS}" -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
sudo mysql -u root -p"${MYSQL_ROOT_PASS}" -e "FLUSH PRIVILEGES;"

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
sudo sed -i "s/DB_DATABASE=.*/DB_DATABASE="${DB_NAME}"/" /var/www/${PROJECT_NAME}/.env
sudo sed -i "s/DB_USERNAME=.*/DB_USERNAME="${DB_USER}"/" /var/www/${PROJECT_NAME}/.env
sudo sed -i "s/DB_PASSWORD=.*/DB_PASSWORD="${DB_PASS}"/" /var/www/${PROJECT_NAME}/.env

# Install PHP dependencies
echo "Installing PHP dependencies..."
cd /var/www/${PROJECT_NAME}
composer install --no-dev --optimize-autoloader
php artisan key:generate

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
sudo ln -sf ${NGINX_CONF} /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# Set up Node.js
if confirm "Do you want to set up Node.js?"; then
    echo "Installing Node.js version ${NODE_VERSION}..."
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | sudo -E bash -
    sudo apt install -y nodejs
    cd /var/www/${PROJECT_NAME}
    npm install && npm run build
fi

# Set up SSL
if confirm "Do you want to install SSL certificate?"; then
    echo "WARNING: Before proceeding, ensure your domain's DNS A record points to this server's IP address."
    if confirm "Have you configured the DNS settings?"; then
        sudo certbot --nginx -d ${DOMAIN} -d www.${DOMAIN}
        sudo certbot renew --dry-run
    else
        echo "Please configure DNS settings first and run SSL installation later."
    fi
fi

# Migrate Database
if confirm "Do you want to migrate database?"; then
    php artisan migrate --seed
fi

# Final message
echo "Laravel project ${PROJECT_NAME} has been successfully set up!"
echo "Access it via ${DOMAIN}"
