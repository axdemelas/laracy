ARG PHP_CLI_VERSION=7.3
FROM php:${PHP_CLI_VERSION}-cli AS laracy_cli

WORKDIR /app

COPY --from=composer /usr/bin/composer /usr/bin/composer

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

ARG PHP_CLI_EXTENSIONS
RUN if [ -n "$PHP_CLI_EXTENSIONS" ]; then install-php-extensions $PHP_CLI_EXTENSIONS; fi

ARG NODE_VERSION=16
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -

RUN apt-get update && apt-get install -y --no-install-recommends \
    zip \
    unzip \
    nodejs \
    python \
    ; \
    rm -rf /var/lib/apt/lists/*

CMD ["echo", "Hey! There's nothing to start. Type: laracy -h"]

FROM laracy_cli AS laracy_integrate_cli

COPY --from=source_path . .

CMD [ "tail", "-f", "/dev/null" ]