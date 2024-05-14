# Laracy

Handy CLI for working with legacy Laravel projects.

> This is an experimental repository that abstracts [Docker Compose](https://docs.docker.com/compose/) containers for older versions of Laravel where [Sail](https://laravel.com/docs/11.x) is not available.

## Why?

Suppose you want to contribute to a Laravel project that relies on system requirements that don't match with your local environment (e.g., Laravel <= 8.x).

For this case, you can use [Laradock](https://laradock.io/) or simply:

```sh
$ cd /path/to/legacy-laravel-project

$ git clone https://github.com/axdemelas/laracy

$ echo SOURCE_PATH=../ > laracy/.env

$ laracy composer install
$ laracy npm install
$ laracy npm run dev
$ laracy php artisan serve
```

## Getting Started

Add the `laracy` shell alias to your `.zshrc` or `.bashrc`:

```sh
alias laracy='laracy/bin/laracy.sh'

# To ensure `laracy` command under multiple folder structures use instead:
#
# alias laracy='$(
#   if [ -f laracy/bin/laracy.sh ]; then echo laracy/bin/laracy.sh; \
#   elif [ -f ../laracy/bin/laracy.sh ]; then echo ../laracy/bin/laracy.sh; \
#   elif [ -f ../bin/laracy.sh ]; then echo ../bin/laracy.sh; \
#   else echo bin/laracy.sh; \
#   fi \
# )'
```

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

# Start Laravel's development server on "http://0.0.0.0:8000"
$ laracy php artisan serve

# Use "--" as a separator for specifying Docker Compose Run options.
# For example, to publish a given port:
$ laracy -p 8001:8001 -- php -S 0.0.0.0:8001 -t public

# Running detached:
$ laracy -d -p 8000:8000 -- php artisan serve --host=0.0.0.0

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
# Path to the root of Laravel app.
SOURCE_PATH=./my-laravel-project

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

## Creating Local CI Pipelines

You can define and run simple CI Pipelines bounded to the CLI and Server containers.

First, create a YML file under `./pipelines/integrate` directory describing the steps for automated execution. For example:

```yml
- Welcome: echo \"Hello, default pipeline!\"

- Install Composer Dependencies: composer install --no-interaction --prefer-dist

# - Run static analysis with PHPStan: /app/vendor/bin/phpstan analyze

# - Check linting: php artisan lint

# - Check code formatting: php-cs-fixer fix --diff --dry-run

# - Run Laravel Tests: php artisan test

- Install NPM Dependencies: npm install

# - Run NPM Lint: npm lint

# - Run NPM Test: npm test

- Compiling assets: npm run prod
```

And then execute:

```sh
$ laracy action integrate

# Laracy Integrate: Executing default pipeline with 4 steps on a cli-based image

# Step 1: Welcome
# ...
# Step 1: Completed

# Step 2: Install Composer Dependencies
# ...
# Step 2: Completed

# Step 3: Install NPM Dependencies
# ...
# Step 3: Completed

# Step 4: Compiling assets
# ...
# Step 4: Completed

# Laracy Integrate: Execution of default pipeline has finished!
```

### Custom Pipelines

Create files for specific pipelines and execute them passing `--pipeline` and `--build` parameters:

```sh
# Execute tasks from "./pipelines/integrate/default.yml" on a CLI-based container.
$ laracy action integrate

# Execute tasks from "./pipelines/integrate/backend.yml" on a CLI-based container.
$ laracy action integrate --pipeline backend

# Execute tasks from "./pipelines/integrate/frontend.yml" on a CLI-based container.
$ laracy action integrate --pipeline frontend --build cli

# Execute tasks from "./pipelines/integrate/performance.yml" on a Server-based container.
$ laracy action integrate --pipeline performance --build server
```

## Do You Really Need This?

Probably not.

However, if you're an advanced user who doesn't want to waste time configuring the development environment, you may find this useful.

Also, ensure to keep your Laravel framework on the long-term support version for essential bug and security fixes.