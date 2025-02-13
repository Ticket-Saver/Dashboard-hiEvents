FROM daveearley/hi.events-all-in-one

# Instalar Node.js usando apk (Alpine package manager)
RUN apk update && apk add --no-cache \
    nodejs \
    npm

# Copiar todo el proyecto
COPY backend /app/backend
COPY frontend /app/frontend

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