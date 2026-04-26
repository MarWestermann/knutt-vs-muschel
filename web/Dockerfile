# syntax=docker/dockerfile:1.7

# ---------- Stage 1: Build ----------
FROM node:22-alpine AS build
WORKDIR /app

ENV CI=1

# Abhängigkeiten zuerst (besseres Layer-Caching) – inkl. devDeps für den Build
COPY package.json package-lock.json ./
RUN npm ci --include=dev

# Restliche Quellen
COPY . .

# Vue/Vite-Build (erzeugt /app/dist)
RUN NODE_ENV=production npm run build

# ---------- Stage 2: Runtime ----------
FROM nginx:1.27-alpine AS runtime

# Eigene nginx-Konfiguration für SPA-Routing
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Statische Build-Artefakte
COPY --from=build /app/dist /usr/share/nginx/html

# Als nicht-root laufen (nginx-Image nutzt /var/cache/nginx etc.)
RUN chown -R nginx:nginx /usr/share/nginx/html /var/cache/nginx /var/log/nginx \
 && touch /var/run/nginx.pid \
 && chown nginx:nginx /var/run/nginx.pid

USER 101:101

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/healthz || exit 1

CMD ["nginx", "-g", "daemon off;"]
