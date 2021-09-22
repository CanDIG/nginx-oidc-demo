FROM openresty/openresty:focal

LABEL maintainer="Amanjeev Sethi <aj@amanjeev.com>"

RUN apt update && apt upgrade -y
RUN apt install -y --no-install-recommends  jq

RUN luarocks install lua-resty-openidc
RUN luarocks install lua-cjson

# GENERATE SELF-SIGNED certificate for 127.0.0.1.xip.io
RUN openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=CA/ST=ON/L=Toronto City/O=ICE/CN=nginx" \
    -keyout /etc/ssl/certs/nginx_server.key  -out /etc/ssl/certs/nginx_server.crt

COPY default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
EXPOSE 8081
EXPOSE 443