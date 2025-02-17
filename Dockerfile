FROM daveearley/hi.events-all-in-one

# Instalar Node.js y npm
RUN apk update && apk add --no-cache \
    nodejs \
    npm

# Copiar archivos del backend
COPY backend/database/migrations /app/backend/database/migrations/
COPY backend/app/Models/Event.php /app/backend/app/Models/Event.php
COPY backend/app/Models/Ticket.php /app/backend/app/Models/Ticket.php
COPY backend/app/Http/Controllers/Api/EventController.php /app/backend/app/Http/Controllers/Api/EventController.php
COPY backend/app/Http/Resources/EventResource.php /app/backend/app/Http/Resources/EventResource.php

# Copiar todo el directorio src del frontend
COPY frontend/src /app/frontend/src

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