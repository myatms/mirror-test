# Set up Laravel after main deployment. Called from CodeDeploy's
# appspec.yml.

# Move the previously downloaded .env file to the right place.
composer create-project bagisto/bagisto --working-dir=/var/www/html
sudo rm -rf /var/www/html/bagisto/.env
sudo mv /tmp/env.txt /var/www/html/bagisto/.env
sudo rm -rf /etc/nginx/nginx.conf
sudo mv /tmp/nginx.conf /etc/nginx/nginx.conf

sudo php /var/www/html/bagisto/artisan key:generate
sudo php /var/www/html/bagisto/artisan migrate --force
sudo php /var/www/html/bagisto/artisan db:seed
echo "0" | sudo php /var/www/html/bagisto/artisan vendor:publish
sudo php /var/www/html/bagisto/artisan storage:link

# Run production optimizations.

sudo php /var/www/app/artisan config:cache
sudo php /var/www/app/artisan optimize
sudo php /var/www/app/artisan route:cache
sudo chmod -R 775 /var/www/html/bagisto/storage
sudo rm -rf /var/www/html/bagisto/.git

# Reload php-fpm to clear OPcache.
sudo systemctl restart php-fpm
sudo systemctl restart nginx

touch /tmp/deployment-done

