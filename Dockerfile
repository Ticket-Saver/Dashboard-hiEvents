FROM daveearley/hi.events-all-in-one

# Verificar la versión de PHP y el sistema operativo
RUN php -v && cat /etc/os-release

# Intentar instalar las dependencias necesarias (para Alpine Linux)
RUN if command -v apk >/dev/null 2>&1; then \
        apk update && apk add --no-cache \
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
        php-pcntl; \
    # Para Debian/Ubuntu
    elif command -v apt-get >/dev/null 2>&1; then \
        apt-get update && apt-get install -y \
        nodejs \
        npm \
        php-gd \
        php-zip \
        php-xml \
        php-mbstring \
        php-pdo \
        php-mysql \
        php-intl \
        php-redis \
        php-sodium \
        php-pcntl \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*; \
    fi

# Copiar todo el proyecto
COPY . /app
WORKDIR /app

# Instalar dependencias de PHP en el backend
WORKDIR /app/backend
RUN composer install --no-dev --ignore-platform-reqs
RUN php artisan config:clear
RUN php artisan cache:clear

# Instalar dependencias y construir el frontend para SSR
WORKDIR /app/frontend
RUN npm install
RUN npm run build:ssr:client
RUN npm run build:ssr:server

# Copiar el script de inicio y hacerlo ejecutable
WORKDIR /app
COPY digitalocean-start.sh /digitalocean-start.sh
RUN chmod +x /digitalocean-start.sh

# Configurar permisos
RUN chown -R www-data:www-data /app/backend/storage /app/backend/bootstrap/cache
RUN chmod -R 775 /app/backend/storage /app/backend/bootstrap/cache

# Configurar variables de entorno para Stripe
ENV STRIPE_KEY=pk_test
ENV STRIPE_SECRET=sk_test

# Punto de entrada
CMD ["sh", "-c", "export VITE_FRONTEND_URL=${APP_FRONTEND_URL:-\"/\"} && echo \"Starting with VITE_FRONTEND_URL=${VITE_FRONTEND_URL}\" && /digitalocean-start.sh"]