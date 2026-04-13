FROM nginx:stable-alpine
RUN apk add --no-cache nginx-module-njs
COPY nginx.conf /etc/nginx/nginx.conf
COPY hmac_verify.js /etc/nginx/hmac_verify.js
