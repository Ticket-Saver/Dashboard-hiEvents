FROM daveearley/hi.events-all-in-one

COPY backend/database/migrations/* /app/backend/database/migrations/ 
COPY frontend/src/mutations/* /app/frontend/src/mutations/
COPY frontend/src/components/*  /app/frontend/src/components/
COPY digitalocean-start.sh /digitalocean-start.sh
RUN chmod +x /digitalocean-start.sh

CMD ["/digitalocean-start.sh"]