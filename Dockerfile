
FROM ghcr.io/cirruslabs/flutter:stable AS flutter-build

WORKDIR /app/frontend
COPY frontend/ ./
RUN flutter pub get
RUN flutter build web --release

FROM node:20-bookworm-slim

WORKDIR /app/backend

COPY backend/package*.json ./
RUN npm install --omit=dev

COPY backend/ ./

COPY --from=flutter-build /app/frontend/build/web /app/frontend-build

ENV NODE_ENV=production

CMD ["npm", "start"]
