#!/bin/sh
set -e

# Configurar variables de entorno del frontend
export VITE_FRONTEND_URL=${APP_FRONTEND_URL:-"/"}

echo "Starting with the following environment variables:"
echo "VITE_FRONTEND_URL=${VITE_FRONTEND_URL}"

# Ir al directorio del backend
cd /app/backend

# Ejecutar migraciones
php artisan migrate --force

# Limpiar cachés
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan storage:link

# Ajustar permisos
chown -R www-data:www-data /app/backend/storage /app/backend/bootstrap/cache
chmod -R 775 /app/backend/storage /app/backend/bootstrap/cache

# Continuar con el inicio normal
cd /
if [ -f /startup.sh ]; then
  echo "Ejecutando /startup.sh"
  exec /startup.sh
else
  echo "Ejecutando supervisord"
  exec supervisord -n
fi