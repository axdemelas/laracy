# Laracy

Handy CLI for working with legacy Laravel projects.

## Why?

Suppose you want to contribute on a Laravel project that relies on PHP 7.3 and Node.js v16 (e.g. Laravel 5.x) but you don't have these installed.

For this case you can use [Laradock](https://laradock.io/) or just:

```sh
$ git clone https://github.com/axdemelas/laracy && cd laracy

$ mv /path/to/laravel-legacy-project src

$ laracy composer install
$ laracy npm install
$ laracy npm run dev
$ laracy -p 8000:8000 -- php artisan serve
```

## Getting Started

Add the `laracy` shell alias to your `.zshrc` or `.bashrc`:

```sh
alias laracy='$(
  if [ -f laracy/bin/laracy.sh ]; then echo laracy/bin/laracy.sh; \
  elif [ -f ../laracy/bin/laracy.sh ]; then echo ../laracy/bin/laracy.sh; \
  elif [ -f ../bin/laracy.sh ]; then echo ../bin/laracy.sh; \
  else echo bin/laracy.sh; \
  fi \
)'
```

> This ensures `laracy` to work under multiple folder structures. Feel free to change it.

Reload the terminal and try it out:

```
$ laracy help
```

## Common Commands

```sh
$ laracy ls /app
$ laracy php --version
$ laracy php -m
$ laracy composer --version
$ laracy node --version
$ laracy npm --version
$ laracy python --version

$ laracy composer create-project --prefer-dist laravel/laravel . "5.5.*"
$ laracy composer install
$ laracy npm install
$ laracy npm run prod

# Use "--" as a separator for specifying Docker Compose Run options.
# For example, to publish a given port:
$ laracy -p 8000:8000 -- php -S 0.0.0.0:8000 -t public

# Running detached:
$ laracy -d -p 8000:8000 -- php artisan serve

# Use docker commands to view logs and stop the detached containers.
# For example:
$ laracy -d -- npm run watch
# [container_id]
$ docker logs [container_id] -tf
$ docker stop [container_id]

# The CLI container is responsible for the common tools available
# on `laracy` command like PHP, Composer, Node/NPM, Python, etc.
# To manipulate it use:
$ laracy cli build
$ laracy cli build --no-cache
$ laracy cli up
$ laracy cli stop
$ laracy cli down

# The Server is a container for HTTP serving with PHP-FPM and
# Nginx as reverse proxy. To manipulate it:
$ laracy server build
$ laracy server build --no-cache
$ laracy server up
$ laracy server up -d
$ laracy server up --build -d
$ laracy server stop
$ laracy server down
```

## Custom Environments

Create a `.env` file in the root of the project and set the variables:

```dotenv
# Path to the Laravel app.
SOURCE_PATH=./my-custom-dir

# PHP CLI version.
PHP_CLI_VERSION=7.3

# PHP FPM version.
PHP_FPM_VERSION=7.3

# Node.JS version on CLI.
NODE_VERSION=16

# List of PHP extensions to be installed on CLI.
# Refer: https://github.com/mlocati/docker-php-extension-installer
PHP_CLI_EXTENSIONS=gd xdebug

# List of PHP extensions to be installed on PHP-FPM.
# Refer: https://github.com/mlocati/docker-php-extension-installer
PHP_FPM_EXTENSIONS=gd

# Nginx server port.
NGINX_PORT=80
```

Then rebuild necessary images (CLI and/or Server). For example:

```sh
$ laracy php -v
# PHP 7.3 (cli)

$ PHP_CLI_VERSION=7.1 laracy cli build

$ laracy php -v
# PHP 7.1 (cli)
```

Also possible:

```sh
$ laracy server up -d

$ docker compose exec laracy_server sh -c "php-fpm -v"
# PHP 7.3 (fpm)

$ laracy server down

$ PHP_FPM_VERSION=7.1 laracy server build

$ laracy server up -d

$ docker compose exec laracy_server sh -c "php-fpm -v"
# PHP 7.1 (fpm)
```

## Do You Really Need This?

Probably not. This is an **experimental** repository.

It simply abstracts [Docker Compose](https://docs.docker.com/compose/) containers for older versions of Laravel where [Sail](https://laravel.com/docs/11.x) is not available.

However, if you're an advanced user who doesn't want to waste time configuring the development environment, you may find this useful.