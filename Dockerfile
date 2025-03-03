FROM daveearley/hi.events-all-in-one

COPY digitalocean-start.sh /digitalocean-start.sh
RUN chmod +x /digitalocean-start.sh

COPY . /app
WORKDIR /app

RUN yarn install  # Asumiendo que usas yarn, ajusta según tu gestor de paquetes

CMD ["/digitalocean-start.sh"]