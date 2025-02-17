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

# Copiar todo el backend
COPY backend /app/backend

# Instalar dependencias de PHP
WORKDIR /app/backend
RUN composer install --no-dev --optimize-autoloader --ignore-platform-reqs

# Copiar todo el frontend
COPY frontend /app/frontend

# Reconstruir el frontend
WORKDIR /app/frontend
RUN npm install
RUN npm run build

# Copiar el script de inicio
WORKDIR /
COPY digitalocean-start.sh /digitalocean-start.sh
RUN chmod +x /digitalocean-start.sh

CMD ["/digitalocean-start.sh"]