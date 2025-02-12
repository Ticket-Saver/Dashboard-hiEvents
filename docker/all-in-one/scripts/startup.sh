#!/bin/sh

cd /app/backend

# Ejecutar migraciones de la base de datos
echo "Ejecutando migraciones de la base de datos..."
php artisan migrate --force

php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan storage:link

chown -R www-data:www-data /app/backend
chmod -R 775 /app/backend/storage /app/backend/bootstrap/cache

exec /usr/bin/supervisord -c /etc/supervisord.conf
