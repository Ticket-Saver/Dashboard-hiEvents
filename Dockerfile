FROM daveearley/hi.events-all-in-one

# Instalar Node.js y npm
RUN apk update && apk add --no-cache \
    nodejs \
    npm

# Copiar todo el backend
COPY backend /app/backend

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