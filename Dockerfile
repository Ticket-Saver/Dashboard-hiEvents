FROM daveearley/hi.events-all-in-one

# Instalar Node.js usando apk (Alpine package manager)
RUN apk update && apk add --no-cache \
    nodejs \
    npm

# Copiar migraciones
COPY backend/database/migrations /app/backend/database/migrations/

# Copiar archivos del frontend
COPY frontend/src /app/frontend/src
COPY frontend/package*.json /app/frontend/
COPY frontend/vite.config.ts /app/frontend/
COPY frontend/tsconfig*.json /app/frontend/
COPY frontend/index.html /app/frontend/

# Construir el frontend
WORKDIR /app/frontend
RUN npm install
RUN npm run build

WORKDIR /
COPY digitalocean-start.sh /digitalocean-start.sh
RUN chmod +x /digitalocean-start.sh

CMD ["/digitalocean-start.sh"]