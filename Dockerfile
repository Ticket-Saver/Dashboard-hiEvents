FROM daveearley/hi.events-all-in-one

COPY backend/database/migrations/* /app/backend/database/migrations/
COPY digitalocean-start.sh /digitalocean-start.sh
RUN chmod +x /digitalocean-start.sh

CMD ["/digitalocean-start.sh"]