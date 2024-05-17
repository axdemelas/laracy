# Laracy

Handy CLI for interacting with Laravel projects via [Docker Compose](https://docs.docker.com/compose/).

## Why?

Suppose you want to contribute to a Laravel project that relies on system requirements that don't match with your local environment nor have [Sail](https://laravel.com/docs/11.x/sail) available.

```sh
$ cd /path/to/laravel-project

$ php artisan serve
# command not found: php
```

For this case, you can use [Laradock](https://laradock.io/) or simply:

```sh
$ git clone https://github.com/axdemelas/laracy

# Set the enviroment:
$ echo LARAVEL_ROOT=../ >> laracy/.env
$ echo PHP_VERSION=7.3 >> laracy/.env
$ echo NODE_VERSION=16 >> laracy/.env
$ echo PHP_EXTENSIONS='gd xdebug' >> laracy/.env

# Make CLI available:
$ alias laracy='laracy/bin/cli.sh'

# Install dependencies and run the application:
$ laracy composer install
$ laracy npm install
$ laracy npm run dev
$ laracy php artisan serve

# Try it out:
$ curl http://0.0.0.0:8000
```

The instructions above create a development environment with PHP 7.3 (cli), `gd` and `xdebug` extensions, latest Composer version, and Node v16.

If you want to create a PHP-FPM/Nginx environment, use:

```sh
# Set the enviroment:
$ echo PHP_FPM_VERSION=7.3 >> laracy/.env
$ echo PHP_FPM_EXTENSIONS='gd' >> laracy/.env
$ echo NGINX_PORT=80 >> laracy/.env

# Start HTTP serving:
$ laracy server up

# Try it out:
$ curl http://0.0.0.0:80
```

## Common Commands

```sh
# |--------------------------------------------
# | CLI Container
# |
# | Provides development-like interactions
# | with the application code.
# |--------------------------------------------

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

# If you change the value of a environment variable you need to
# rebuild the CLI image:
$ laracy cli build
$ laracy cli build --no-cache

# To stop/remove long-running commands:
$ laracy cli stop
$ laracy cli down

# |--------------------------------------------
# | Server Container
# |
# | Provides a production-like environment to
# | serve the application code.
# |--------------------------------------------

# To manipulate an instance of PHP-FPM and Nginx as reverse proxy
# communicating via unix socket:
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
LARAVEL_ROOT=./my-laravel-project

# PHP CLI version.
PHP_VERSION=7.3

# PHP FPM version.
PHP_FPM_VERSION=7.3

# Node.JS version on CLI.
NODE_VERSION=16

# List of PHP extensions to be installed on CLI.
# Refer: https://github.com/mlocati/docker-php-extension-installer
PHP_EXTENSIONS=gd xdebug

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

$ PHP_VERSION=7.1 laracy cli build

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

## Persistent Shell Alias

Add a laracy alias to `.zshrc` or `.bashrc`:

```sh
alias laracy='laracy/bin/cli.sh'

# To ensure `laracy` command under multiple folder structures use instead:
#
# alias laracy='$(
#   if [ -f laracy/bin/cli.sh ]; then echo laracy/bin/cli.sh; \
#   elif [ -f ../laracy/bin/cli.sh ]; then echo ../laracy/bin/cli.sh; \
#   elif [ -f ../bin/cli.sh ]; then echo ../bin/cli.sh; \
#   else echo bin/cli.sh; \
#   fi \
# )'
```

Reload the terminal and check:

```
$ laracy help
```

## Continuous Integration Playground

You can define and run simple CI Pipelines bounded to the CLI and Server containers.

First, create a YML file under `./pipelines/integrate` directory describing the steps for automated execution. For example:

```yml
- Welcome: echo \"Hello, default pipeline!\"

- Check PHP Version: php -v

- Check Node Version: node -v

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

# Laracy Integrate: Executing default pipeline with 6 steps on a cli-based image
#
# ------------------------------------------
# Step 1: Welcome
#   Hello, default pipeline!
# Step 1: Completed
#
# ------------------------------------------
# Step 2: Check PHP Version
#   PHP 7.3.33 (cli)
# Step 2: Completed
#
# ------------------------------------------
# Step 3: Check Node Version
#   v16.20.2
# Step 3: Completed
#
# ------------------------------------------
# Step 4: Install Composer Dependencies
#   [...]
# Step 4: Completed
#
# ------------------------------------------
# Step 5: Install NPM Dependencies
#   [...]
# Step 5: Completed
#
# ------------------------------------------
# Step 6: Compiling assets
#   [...]
# Step 6: Completed
#
# Laracy Integrate: Execution of default pipeline has finished!
```

The `action integrate` command constructs an isolated container using CLI or Server based images, with a copy of the Laravel code. None of the side-effects of the steps should persist beyond the execution.

Also, when creating the image for CI, you may wish to ignore host folders such as `./vendor`, `./node_modules`, and `./laracy`. To achieve this, add a `.dockerignore` file to the root directory of your Laravel application:

```
vendor
node_modules
laracy
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

## Do You Really Need This Repository?

Probably not. It is **experimental**.

However, if you're an advanced user who doesn't want to waste time configuring the development environment for Laravel projects where [Sail](https://laravel.com/docs/11.x/sail) is not available, you may find this useful.
