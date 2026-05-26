# Dockerfile para backend NestJS
FROM node:18-alpine AS builder

WORKDIR /usr/src/app

# Copiar package y lock para aprovechar cache
COPY package*.json ./

RUN npm ci

# Copiar todo el proyecto y construir
COPY . .
RUN npm run build

# Imagen de producción
FROM node:18-alpine AS production
WORKDIR /usr/src/app

COPY package*.json ./
RUN npm ci --production

COPY --from=builder /usr/src/app/dist ./dist

EXPOSE 3000
ENV NODE_ENV=production
CMD ["node", "dist/main"]
