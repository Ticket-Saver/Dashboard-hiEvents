FROM daveearley/hi.events-all-in-one

# Instalar Node.js usando apk (Alpine package manager)
RUN apk update && apk add --no-cache \
    nodejs \
    npm

# Copiar migraciones
COPY backend/database/migrations /app/backend/database/migrations/

# Copiar solo los componentes modificados del frontend
COPY frontend/src/components/modals/CreateTicketModal /app/frontend/src/components/modals/CreateTicketModal
COPY frontend/src/components/modals/CreateEventModal /app/frontend/src/components/modals/CreateEventModal
COPY frontend/src/components/routes/organizer/OrganizerDashboard /app/frontend/src/components/routes/organizer/OrganizerDashboard

# Copiar archivos de mapas y utilidades necesarias
COPY frontend/src/assets/venue-maps /app/frontend/src/assets/venue-maps
COPY frontend/src/utils/venueMaps.ts /app/frontend/src/utils/
COPY frontend/src/types.ts /app/frontend/src/types.ts

# Copiar archivos de localización
COPY frontend/src/locales /app/frontend/src/locales
COPY frontend/lingui.config.ts /app/frontend/

# Copiar archivos de configuración mínimos necesarios
COPY frontend/package.json frontend/package-lock.json /app/frontend/
COPY frontend/vite.config.ts /app/frontend/

# Reconstruir solo los archivos modificados
WORKDIR /app/frontend
RUN npm install
RUN npm run build

WORKDIR /
COPY digitalocean-start.sh /digitalocean-start.sh
RUN chmod +x /digitalocean-start.sh

CMD ["/digitalocean-start.sh"]