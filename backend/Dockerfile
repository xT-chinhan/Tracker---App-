# Build: docker build -t app-tracker-api backend   (hoặc docker compose --profile api up -d --build)
FROM node:22-alpine AS build
RUN apk add --no-cache openssl
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY prisma ./prisma
RUN npx prisma generate
COPY tsconfig.json tsconfig.build.json nest-cli.json ./
COPY src ./src
# seed.ts + seed-demo.ts (dùng helper trong src/) -> JS để chạy bằng node (không cần ts-node ở image chạy); bỏ devDependencies
RUN npm run build \
 && npx tsc prisma/seed.ts prisma/seed-demo.ts --outDir seed-dist --rootDir . --module commonjs --target ES2022 \
      --esModuleInterop --skipLibCheck --experimentalDecorators --emitDecoratorMetadata \
 && npm prune --omit=dev

FROM node:22-alpine
RUN apk add --no-cache openssl
WORKDIR /app
ENV NODE_ENV=production PORT=3000
COPY --from=build /app/package.json ./
# Trong image: npm run db:seed / db:seed:demo chạy bản JS đã biên dịch
RUN npm pkg set 'scripts.db:seed=node seed-dist/prisma/seed.js' 'scripts.db:seed:demo=node seed-dist/prisma/seed-demo.js'
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/prisma ./prisma
COPY --from=build /app/seed-dist ./seed-dist
COPY --from=build /app/dist ./dist
USER node
EXPOSE 3000
HEALTHCHECK --interval=15s --timeout=3s --start-period=30s CMD wget -qO- http://127.0.0.1:${PORT}/api/health >/dev/null || exit 1
# Chờ DB (tối đa ~30s) -> migrate deploy -> seed (idempotent: danh mục hệ thống + admin nếu có ADMIN_EMAIL/ADMIN_PASSWORD)
# -> SEED_DEMO=true thì nạp (lại) dữ liệu demo -> API
CMD ["sh", "-c", "i=0; until npx prisma migrate deploy; do i=$((i+1)); [ $i -ge 15 ] && exit 1; echo 'Chờ DB...'; sleep 2; done; node seed-dist/prisma/seed.js && if [ \"$SEED_DEMO\" = true ]; then node seed-dist/prisma/seed-demo.js; fi && exec node dist/main"]
