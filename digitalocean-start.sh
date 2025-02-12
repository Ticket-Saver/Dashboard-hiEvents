#!/bin/bash

# Asegurarse de que el script tenga permisos de ejecución
chmod +x /digitalocean-start.sh

export VITE_FRONTEND_URL=${APP_FRONTEND_URL:-"/"}

echo "Starting with the following environment variables:"
echo "VITE_FRONTEND_URL=${VITE_FRONTEND_URL}"

cd /app/backend

# Asegurarse de que la base de datos esté lista
php artisan migrate:status
# Ejecutar migraciones pendientes
php artisan migrate --force

exec /startup.sh