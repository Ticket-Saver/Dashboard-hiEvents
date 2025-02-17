FROM daveearley/hi.events-all-in-one

# Instalar Node.js y npm
RUN apk update && apk add --no-cache \
    nodejs \
    npm

# Copiar archivos del backend
COPY backend/database/migrations /app/backend/database/migrations/

# Copiar archivos del frontend
COPY frontend/src/components/modals/CreateEventModal /app/frontend/src/components/modals/CreateEventModal
COPY frontend/src/components/modals/CreateTicketModal /app/frontend/src/components/modals/CreateTicketModal
COPY frontend/src/components/routes/event /app/frontend/src/components/routes/event
COPY frontend/src/components/common/Editor /app/frontend/src/components/common/Editor
COPY frontend/src/components/common/Modal /app/frontend/src/components/common/Modal
COPY frontend/src/components/common/Card /app/frontend/src/components/common/Card
COPY frontend/src/assets/venue-maps /app/frontend/src/assets/venue-maps
COPY frontend/src/locales /app/frontend/src/locales
COPY frontend/src/utils/venueMaps.ts /app/frontend/src/utils/venueMaps.ts
COPY frontend/src/queries/useGetTickets.ts /app/frontend/src/queries/useGetTickets.ts
COPY frontend/src/queries/useGetEvent.ts /app/frontend/src/queries/useGetEvent.ts

# Copiar archivos de configuración del frontend
COPY frontend/package.json /app/frontend/
COPY frontend/package-lock.json /app/frontend/
COPY frontend/tsconfig.json /app/frontend/
COPY frontend/vite.config.ts /app/frontend/
COPY frontend/index.html /app/frontend/
COPY frontend/lingui.config.ts /app/frontend/

# Reconstruir el frontend
WORKDIR /app/frontend
RUN npm install
RUN npm run build

# Copiar el script de inicio
WORKDIR /
COPY digitalocean-start.sh /digitalocean-start.sh
RUN chmod +x /digitalocean-start.sh

CMD ["/digitalocean-start.sh"]