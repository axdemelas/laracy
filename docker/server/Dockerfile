ARG PHP_FPM_VERSION=7.3
FROM php:${PHP_FPM_VERSION}-fpm AS laracy_server

WORKDIR /var/www/html

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

ARG PHP_FPM_EXTENSIONS
RUN if [ -n "$PHP_FPM_EXTENSIONS" ]; then install-php-extensions $PHP_FPM_EXTENSIONS; fi

RUN apt-get update && apt-get install -y nginx \
    ; \
    rm -rf /var/lib/apt/lists/*

RUN rm /etc/nginx/sites-enabled/default

COPY ./proxy/nginx.conf /etc/nginx/conf.d/default.conf

COPY ./fpm/zz-docker.conf /usr/local/etc/php-fpm.d

COPY ./start-server.sh /usr/local/bin

RUN chmod +x /usr/local/bin/start-server.sh

ENTRYPOINT [ "start-server.sh" ]

FROM laracy_server AS laracy_integrate_server

COPY --from=source_path . .

CMD [ "tail", "-f", "/dev/null" ]