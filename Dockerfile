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

# ---- Nginx config (stock listens on 5000, matches Railway PORT) ----
COPY var/docker/nginx.conf /etc/nginx/nginx.conf

# ---- Runtime: nginx + pm2 ----
# PORT=5000 is Railway's external port; nginx listens there.
# Backend needs PORT=3000 (set in ecosystem.config.js) to avoid clash.
EXPOSE 5000
CMD ["sh", "-c", "pnpm run prisma-db-push && nginx && pm2 start ecosystem.config.js && pm2 logs"]
