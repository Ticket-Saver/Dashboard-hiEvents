FROM daveearley/hi.events-all-in-one

# Copiar migraciones
COPY backend/database/migrations /app/backend/database/migrations/

# Copiar archivos del frontend (src)
COPY frontend/src/mutations /app/frontend/src/mutations/
COPY frontend/src/components/modals/CreateEventModal /app/frontend/src/components/modals/CreateEventModal/
COPY frontend/src/components/modals/CreateTicketModal /app/frontend/src/components/modals/CreateTicketModal/
COPY frontend/src/components/routes/organizer/OrganizerDashboard /app/frontend/src/components/routes/organizer/OrganizerDashboard/

COPY digitalocean-start.sh /digitalocean-start.sh
RUN chmod +x /digitalocean-start.sh

CMD ["/digitalocean-start.sh"]