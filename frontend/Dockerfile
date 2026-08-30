FROM node:20-slim AS build

WORKDIR /app

# Lockfile first for layer caching; `npm ci` installs it exactly and fails on
# drift, unlike `npm install` which may silently update it.
COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM nginx:1.27-alpine AS final

# The official nginx image runs envsubst over /etc/nginx/templates/*.template
# at startup and writes the result to /etc/nginx/conf.d/. It only substitutes
# variables that exist in the environment, so nginx's own $uri is left intact.
COPY nginx.conf.template /etc/nginx/templates/default.conf.template

# Vite resolves import.meta.env at BUILD time, which is too early to know the
# backend's Cloud Run URL. This regenerates config.js at container start
# instead, so one image works unchanged in any environment.
COPY config.js.template /etc/nginx/config.js.template
COPY --chmod=755 docker-entrypoint.d/40-config-js.sh /docker-entrypoint.d/40-config-js.sh

COPY --from=build /app/dist /usr/share/nginx/html

ENV PORT=8080
ENV VITE_API_URL="http://localhost:8000"
EXPOSE 8080

# No CMD: the base image's entrypoint runs /docker-entrypoint.d/*.sh in order
# and then starts nginx.
