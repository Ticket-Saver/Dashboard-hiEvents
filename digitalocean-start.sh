#!/bin/bash

echo "Configurando variables de entorno..."
export VITE_FRONTEND_URL=${APP_FRONTEND_URL:-"http://localhost:3000"}

echo "Iniciando la aplicación..."
# Comandos para iniciar tu aplicación, por ejemplo:
php artisan serve --host=0.0.0.0 --port=8080
# o
yarn start