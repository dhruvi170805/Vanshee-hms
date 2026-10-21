
# Stage 1: Build the Flutter web frontend
FROM ghcr.io/cirruslabs/flutter:stable AS flutter-build

WORKDIR /app/frontend
COPY frontend/ ./
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Run the Node.js backend
FROM node:20-bookworm-slim

WORKDIR /app/backend

COPY backend/package*.json ./
RUN npm install --omit=dev

COPY backend/ ./

# Copy the built Flutter website into the backend container
COPY --from=flutter-build /app/frontend/build/web /app/frontend-build

ENV NODE_ENV=production

EXPOSE 10000

CMD ["npm", "start"]
