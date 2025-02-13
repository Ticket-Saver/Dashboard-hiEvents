FROM daveearley/hi.events-all-in-one

# Instalar Node.js usando apk (Alpine package manager)
RUN apk update && apk add --no-cache \
    nodejs \
    npm

# Copiar migraciones
COPY backend/database/migrations /app/backend/database/migrations/

# Copiar componentes del frontend
COPY frontend/src/components/modals/CreateTicketModal /app/frontend/src/components/modals/CreateTicketModal
COPY frontend/src/components/modals/CreateEventModal /app/frontend/src/components/modals/CreateEventModal
COPY frontend/src/components/routes/organizer/OrganizerDashboard /app/frontend/src/components/routes/organizer/OrganizerDashboard
COPY frontend/src/components/common/Editor /app/frontend/src/components/common/Editor
COPY frontend/src/components/common/Modal /app/frontend/src/components/common/Modal
COPY frontend/src/components/common/Card /app/frontend/src/components/common/Card
COPY frontend/src/components/routes/event /app/frontend/src/components/routes/event

# Copiar archivos de rutas, utilidades y dependencias
COPY frontend/src/utils /app/frontend/src/utils
COPY frontend/src/queries /app/frontend/src/queries
COPY frontend/src/lib /app/frontend/src/lib
COPY frontend/src/assets /app/frontend/src/assets
COPY frontend/src/router /app/frontend/src/router

# Copiar archivos de localización
COPY frontend/src/locales /app/frontend/src/locales
COPY frontend/lingui.config.ts /app/frontend/

# Copiar archivos de configuración necesarios
COPY frontend/package*.json /app/frontend/
COPY frontend/tsconfig*.json /app/frontend/
COPY frontend/vite.config.ts /app/frontend/
COPY frontend/index.html /app/frontend/

# Reconstruir solo los archivos modificados
WORKDIR /app/frontend
RUN npm install
RUN npm run build

WORKDIR /
COPY digitalocean-start.sh /digitalocean-start.sh
RUN chmod +x /digitalocean-start.sh

CMD ["/digitalocean-start.sh"]