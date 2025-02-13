FROM daveearley/hi.events-all-in-one

# Instalar Node.js y PHP dependencies
RUN apk update && apk add --no-cache \
    nodejs \
    npm \
    composer

# Copiar todo el proyecto
COPY backend /app/backend
COPY frontend /app/frontend

# Instalar dependencias del backend
WORKDIR /app/backend
RUN composer install --no-dev --optimize-autoloader
RUN php artisan config:clear
RUN php artisan cache:clear

# Configurar variables de entorno para el build
ENV VITE_API_URL_SERVER=${VITE_API_URL_SERVER:-"http://localhost:80/api"}
ENV VITE_API_URL_CLIENT=${VITE_API_URL_CLIENT:-"/api"}
ENV VITE_FRONTEND_URL=${VITE_FRONTEND_URL:-"/"}

# Reconstruir el frontend
WORKDIR /app/frontend
RUN npm install
RUN npm run build

WORKDIR /
COPY digitalocean-start.sh /digitalocean-start.sh
RUN chmod +x /digitalocean-start.sh

CMD ["/digitalocean-start.sh"]