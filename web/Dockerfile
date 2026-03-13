FROM node:20-alpine AS deps
WORKDIR /app

COPY package*.json ./
RUN npm ci

FROM node:20-alpine AS build
WORKDIR /app

ARG NEXT_PUBLIC_LETSGROW_EARLY_ACCESS_URL
ENV NEXT_PUBLIC_LETSGROW_EARLY_ACCESS_URL=${NEXT_PUBLIC_LETSGROW_EARLY_ACCESS_URL}

COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app

ARG NEXT_PUBLIC_LETSGROW_EARLY_ACCESS_URL
ENV NODE_ENV=production
ENV PORT=3000
ENV NEXT_PUBLIC_LETSGROW_EARLY_ACCESS_URL=${NEXT_PUBLIC_LETSGROW_EARLY_ACCESS_URL}

COPY --from=build /app/public ./public
COPY --from=build /app/.next/standalone ./
COPY --from=build /app/.next/static ./.next/static

EXPOSE 3000

CMD ["sh", "-c", "HOSTNAME=0.0.0.0 exec node server.js"]
