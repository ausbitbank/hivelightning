# develop stage
FROM node:lts-alpine as develop-stage
WORKDIR /app
COPY package*.json ./
RUN yarn global add @quasar/cli
COPY . .
# COPY public/ .
# COPY src/ .
# COPY quasar.conf.js ./
# COPY jsconfig.json ./
# COPY babel.config.js ./
# COPY .postcssrc.js ./
# COPY .editorconfig ./

# build stage
FROM develop-stage as build-stage
RUN yarn
RUN quasar build

# production stage
FROM nginx:stable-alpine as production-stage
COPY --from=build-stage /app/dist/spa /usr/share/nginx/html
COPY ./nginx/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
