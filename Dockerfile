FROM node:lts-alpine3.19 as builder

WORKDIR /app

COPY ./package.json .
COPY ./package-lock.json .
RUN npm install

COPY . .
ARG TMDB_V3_API_KEY
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"

RUN npm run build

FROM node:lts-alpine3.19 as production

WORKDIR /app

COPY --from=builder /app/dist ./dist

EXPOSE 8081

CMD ["node", "dist/index.js"]
