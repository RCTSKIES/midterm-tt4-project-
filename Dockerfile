# Layer 1
FROM node:latest AS builder
WORKDIR /app
COPY ./app/package*.json ./
RUN npm install
COPY ./app/ ./
RUN npm run build 
# in the end I have the /dist

# Layer 2
FROM nginx

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    nginx \
    nodejs \
    npm \
    gettext \
    && apt-get clean

RUN npm install -g pm2

WORKDIR /app

## API
COPY ./api/index.js /app/
COPY ./api/package*.json /app/
RUN npm install

# APP
COPY --from=builder ./app/dist /usr/share/nginx/html

#
COPY default.conf /etc/nginx/conf.d/

RUN echo "API_PORT=3000" >> /app/.env

EXPOSE 8085

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]