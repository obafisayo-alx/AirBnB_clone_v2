#!/usr/bin/env bash

# Install Nginx if not already installed
sudo apt-get update
sudo apt-get -y install nginx

# Create necessary directories if they don't exist
sudo mkdir -p /data/web_static/{releases/test,shared}
sudo touch /data/web_static/releases/test/index.html

# Create fake HTML content
echo "<html>
  <head>
  </head>
  <body>
    Holberton School
  </body>
</html>" | sudo tee /data/web_static/releases/test/index.html > /dev/null

# Create symbolic link
sudo ln -sf /data/web_static/releases/test/ /data/web_static/current

# Give ownership of the /data/ folder to the ubuntu user and group
sudo chown -R ubuntu:ubuntu /data/

# Define the desired Nginx location block
NGINX_LOCATION_BLOCK="    location /hbnb_static {
        alias /data/web_static/current/;
    }"

# Check if the location block for /hbnb_static already exists in the Nginx configuration file
if ! grep -q "location /hbnb_static" /etc/nginx/sites-available/default; then
    # If it doesn't exist, append it to the configuration file
    sudo sed -i '/index.html;/a \\n'"$NGINX_LOCATION_BLOCK" /etc/nginx/sites-available/default
fi

# Restart Nginx
sudo service nginx restart

exit 0
