#!/bin/sh
set -e

echo "Iniciando script de arranque para DigitalOcean..."

# Configurar variables de entorno del frontend
export VITE_FRONTEND_URL=${APP_FRONTEND_URL:-"/"}

echo "Variables de entorno configuradas:"
echo "VITE_FRONTEND_URL=${VITE_FRONTEND_URL}"

# Ir al directorio del backend
cd /app/backend

echo "Ejecutando migraciones..."
php artisan migrate --force

echo "Limpiando cachés..."
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

echo "Creando enlace simbólico para almacenamiento..."
php artisan storage:link

echo "Ajustando permisos..."
chown -R www-data:www-data /app/backend/storage /app/backend/bootstrap/cache
chmod -R 775 /app/backend/storage /app/backend/bootstrap/cache

echo "Configuración completada. Iniciando servidor..."

# Continuar con el inicio normal
cd /
if [ -f /startup.sh ]; then
  echo "Ejecutando /startup.sh"
  exec /startup.sh
else
  echo "Ejecutando supervisord"
  exec supervisord -n
fi