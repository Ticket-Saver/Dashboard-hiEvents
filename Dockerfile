FROM daveearley/hi.events-all-in-one

# Instalar Node.js, npm y dependencias de PHP
RUN apk update && apk add --no-cache \
    nodejs \
    npm \
    php-gd \
    php-zip \
    php-xml \
    php-mbstring \
    php-pdo \
    php-pdo_mysql \
    php-tokenizer \
    php-fileinfo \
    php-intl \
    php-redis \
    php-sodium \
    php-pcntl

# Copiar todo el proyecto
COPY . /app
WORKDIR /app

# Instalar dependencias de PHP en el backend
WORKDIR /app/backend
RUN composer install --no-dev
RUN php artisan config:clear
RUN php artisan cache:clear

# Instalar dependencias y construir el frontend
WORKDIR /app/frontend
RUN npm install
RUN npm run build:csr

# Copiar el script de inicio y hacerlo ejecutable
WORKDIR /app
COPY digitalocean-start.sh /digitalocean-start.sh
RUN chmod +x /digitalocean-start.sh

# Configurar permisos
RUN chown -R www-data:www-data /app/backend/storage /app/backend/bootstrap/cache
RUN chmod -R 775 /app/backend/storage /app/backend/bootstrap/cache

# Punto de entrada
CMD ["sh", "-c", "export VITE_FRONTEND_URL=${APP_FRONTEND_URL:-\"/\"} && echo \"Starting with VITE_FRONTEND_URL=${VITE_FRONTEND_URL}\" && /digitalocean-start.sh"]