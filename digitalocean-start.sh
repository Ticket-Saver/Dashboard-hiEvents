#!/bin/sh

# Configurar variables de entorno del frontend
export VITE_FRONTEND_URL=${APP_FRONTEND_URL:-"/"}

echo "Starting with the following environment variables:"
echo "VITE_FRONTEND_URL=${VITE_FRONTEND_URL}"

# Ejecutar migraciones
cd /app/backend
php artisan migrate --force

# Limpiar cachés
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan storage:link

# Ajustar permisos
chown -R www-data:www-data /app/backend
chmod -R 775 /app/backend/storage /app/backend/bootstrap/cache

# Continuar con el inicio normal
cd /
exec supervisord -n