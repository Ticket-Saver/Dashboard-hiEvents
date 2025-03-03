#!/bin/sh
set -e

echo "Iniciando script de arranque para DigitalOcean..."

# Configurar variables de entorno del frontend
export VITE_FRONTEND_URL=${APP_FRONTEND_URL:-"/"}
export STRIPE_KEY=${STRIPE_KEY:-"pk_test"}
export STRIPE_SECRET=${STRIPE_SECRET:-"sk_test"}

echo "Variables de entorno configuradas:"
echo "VITE_FRONTEND_URL=${VITE_FRONTEND_URL}"
echo "STRIPE_KEY=${STRIPE_KEY}"
echo "STRIPE_SECRET=${STRIPE_SECRET}"

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
php artisan storage:link || true

echo "Ajustando permisos..."
chown -R www-data:www-data /app/backend/storage /app/backend/bootstrap/cache || true
chmod -R 775 /app/backend/storage /app/backend/bootstrap/cache || true

# Verificar que los archivos del frontend existan
echo "Verificando archivos del frontend..."
if [ ! -f /app/frontend/dist/client/index.html ]; then
  echo "ADVERTENCIA: No se encontró el archivo index.html del frontend. Recompilando..."
  cd /app/frontend
  npm run build:ssr:client
  npm run build:ssr:server
fi

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