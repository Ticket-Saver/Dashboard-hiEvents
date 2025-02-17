FROM daveearley/hi.events-all-in-one

# Instalar Node.js y PHP dependencies
RUN apk update && apk add --no-cache \
    nodejs \
    npm \
    composer \
    php82-intl \
    php82-simplexml \
    php82-session \
    php82-sodium \
    php82-fileinfo \
    php82-tokenizer \
    php82-dom \
    php82-xml \
    php82-xmlwriter \
    php82-xmlreader \
    php82-pdo \
    php82-pdo_mysql \
    php82-pdo_sqlite \
    php82-mbstring \
    php82-openssl \
    php82-json \
    php82-curl \
    php82-zip

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