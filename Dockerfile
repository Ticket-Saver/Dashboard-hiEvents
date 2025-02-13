FROM daveearley/hi.events-all-in-one

# Instalar Node.js usando apk (Alpine package manager)
RUN apk update && apk add --no-cache \
    nodejs \
    npm

# Copiar migraciones
COPY backend/database/migrations /app/backend/database/migrations/

# Copiar todo el directorio src del frontend
COPY frontend/src /app/frontend/src/

# Copiar componentes comunes necesarios
COPY frontend/src/components/common/PageTitle /app/frontend/src/components/common/PageTitle
COPY frontend/src/components/common/PageBody /app/frontend/src/components/common/PageBody
COPY frontend/src/components/common/TicketsTable /app/frontend/src/components/common/TicketsTable
COPY frontend/src/components/common/SearchBar /app/frontend/src/components/common/SearchBar
COPY frontend/src/components/common/ToolBar /app/frontend/src/components/common/ToolBar
COPY frontend/src/components/common/TableSkeleton /app/frontend/src/components/common/TableSkeleton
COPY frontend/src/components/common/Pagination /app/frontend/src/components/common/Pagination

# Copiar archivos de mapas
COPY frontend/src/assets/venue-maps /app/frontend/src/assets/venue-maps

# Copiar archivos de configuración necesarios
COPY frontend/package.json /app/frontend/
COPY frontend/package-lock.json /app/frontend/
COPY frontend/tsconfig.json /app/frontend/
COPY frontend/vite.config.ts /app/frontend/
COPY frontend/index.html /app/frontend/
COPY frontend/postcss.config.cjs /app/frontend/

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