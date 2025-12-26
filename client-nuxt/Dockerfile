FROM node:20-alpine AS base

# Install pnpm and build dependencies for native modules
RUN corepack enable && corepack prepare pnpm@latest --activate
RUN apk add --no-cache python3 make g++

WORKDIR /app

# ---- Dependencies ----
FROM base AS deps
COPY package.json pnpm-lock.yaml ./

# Install with explicit script enabling and cache bust comment
# Cache bust: v2
RUN pnpm install --frozen-lockfile --config.enable-scripts=true

# ---- Build ----
FROM base AS builder
COPY --from=deps /app/node_modules ./node_modules
COPY . .
# Rebuild better-sqlite3 to ensure bindings are present in the builder stage
RUN pnpm rebuild better-sqlite3
RUN pnpm run build

# ---- Production ----
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

# Copy built output
COPY --from=builder /app/.output ./.output

EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000 || exit 1

CMD ["node", ".output/server/index.mjs"]
