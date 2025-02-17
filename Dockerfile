FROM daveearley/hi.events-all-in-one

# Copiar solo los archivos modificados
COPY backend/database/migrations /app/backend/database/migrations/
COPY frontend/src/components/modals/CreateEventModal /app/frontend/src/components/modals/CreateEventModal
COPY frontend/src/components/modals/CreateTicketModal /app/frontend/src/components/modals/CreateTicketModal
COPY frontend/src/components/routes/event /app/frontend/src/components/routes/event
COPY frontend/src/assets/venue-maps /app/frontend/src/assets/venue-maps
COPY frontend/src/locales /app/frontend/src/locales

# Copiar el script de inicio
COPY digitalocean-start.sh /digitalocean-start.sh
RUN chmod +x /digitalocean-start.sh

CMD ["/digitalocean-start.sh"]