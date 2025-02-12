FROM daveearley/hi.events-all-in-one

# Copiar migraciones
COPY backend/database/migrations /app/backend/database/migrations/

# Copiar archivos del frontend ya compilados
COPY frontend/dist /app/frontend/dist/

COPY digitalocean-start.sh /digitalocean-start.sh
RUN chmod +x /digitalocean-start.sh

CMD ["/digitalocean-start.sh"]