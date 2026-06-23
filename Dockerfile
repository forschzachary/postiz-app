FROM node:22.20-bookworm-slim

# ---- Build-time env vars (baked into Next.js frontend) ----
ARG NEXT_PUBLIC_BACKEND_URL=https://social.forschfrontiers.com/api
ARG NEXT_PUBLIC_FRONTEND_URL=https://social.forschfrontiers.com
ARG NEXT_PUBLIC_VERSION=forsch-custom

ENV NEXT_PUBLIC_BACKEND_URL=$NEXT_PUBLIC_BACKEND_URL
ENV NEXT_PUBLIC_FRONTEND_URL=$NEXT_PUBLIC_FRONTEND_URL
ENV NEXT_PUBLIC_VERSION=$NEXT_PUBLIC_VERSION

# ---- System deps ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    g++ make python3-pip bash nginx curl gettext-base \
    && rm -rf /var/lib/apt/lists/*

RUN addgroup --system www \
    && adduser --system --ingroup www --home /www --shell /usr/sbin/nologin www \
    && mkdir -p /www \
    && chown -R www:www /www /var/lib/nginx

RUN npm --no-update-notifier --no-fund --global install pnpm@10.6.1 pm2

WORKDIR /app
COPY . /app

# ---- Build ----
RUN pnpm install
RUN NODE_OPTIONS="--max-old-space-size=4096" pnpm run build

# ---- Nginx: template with $PORT support + health endpoint ----
RUN cp var/docker/nginx.conf /etc/nginx/nginx.conf.template \
    && sed -i 's/listen 5000;/listen ${PORT:-5000};/' /etc/nginx/nginx.conf.template \
    && sed -i '/server {/a\        location /health { access_log off; return 200 "ok\\n"; add_header Content-Type text/plain; }' /etc/nginx/nginx.conf.template

# ---- Entrypoint: envsubst nginx template, start nginx + pm2 ----
RUN printf '#!/bin/sh\nenvsubst "$PORT" < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf\nexec nginx && exec pnpm run pm2\n' > /usr/local/bin/start.sh \
    && chmod +x /usr/local/bin/start.sh

EXPOSE 5000
CMD ["/usr/local/bin/start.sh"]
