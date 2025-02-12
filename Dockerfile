FROM daveearley/hi.events-all-in-one

# Copiar migraciones
COPY backend/database/migrations /app/backend/database/migrations/

# Copiar archivos del frontend (recursivamente)
COPY frontend/src/mutations /app/frontend/src/mutations/
COPY frontend/src/components/modals/CreateEventModal /app/frontend/src/components/modals/CreateEventModal/
COPY frontend/src/components/modals/CreateTicketModal /app/frontend/src/components/modals/CreateTicketModal/
COPY frontend/src/components/routes/profile/ManageProfile /app/frontend/src/components/routes/profile/ManageProfile/
COPY frontend/src/components/routes/events/Dashboard /app/frontend/src/components/routes/events/Dashboard/
COPY frontend/src/types.ts /app/frontend/src/types.ts

# Reconstruir el frontend
WORKDIR /app/frontend
RUN npm install
RUN npm run build

WORKDIR /
COPY digitalocean-start.sh /digitalocean-start.sh
RUN chmod +x /digitalocean-start.sh

CMD ["/digitalocean-start.sh"]