# Docker Nuxt3 Mongo NGINX Boilerplate
[Nuxt3](https://nuxt.com/) boilerplate running in an [Docker](https://www.docker.com) environment including [MongoDB](https://www.mongodb.com) and [Mongo-Express](https://github.com/mongo-express/mongo-express) for presistent storage and [NGINX](https://www.nginx.com) as a reverse proxy.

## Notes
> - This Project uses [npm](https://www.npmjs.com) as node package manager.
> - Configuring the setup should be mostly done by [adapting the .env file](#adapt-the-env-file).
> - Adapting the MongoDB setup should always be followed by a [Docker container rebuild](#build-the-docker-container).
> - Waiting for Mongo-Express [release 1.0.0](https://hub.docker.com/_/mongo-express/tags?page=1&name=1.0.0) on [Docker Hub](https://hub.docker.com) to bump MongoDB to [version 6](https://hub.docker.com/_/mongo/tags?page=1&name=6-focal).
> - Nuxt3 roadmap can be found [here](https://nuxt.com/docs/community/roadmap).

## Table of Contents
- [Docker Nuxt3 MongoDB NGINX Boilerplate](#docker-nuxt3-mongo-nginx-boilerplate)
  - [Table of Contents](#table-of-contents)
  - [Getting started](#getting-started)
    - [General](#general)
    - [NGINX](#nginx)
    - [Mongo](#mongo)
    - [Docker](#docker)
    - [Nuxt3](#nuxt3)
  - [License](#license)

## Getting started
### General
* Clone the repository
  * Clone this project to your computer `git clone https://github.com/cinid/docker-nuxt3-mongo-nginx-boilerplate.git`.
* Adapt the .env file
  * Copy the `.env-example` file to `.env` and `adapt the environment variables`.

### NGINX
* Add SSL certificate
  * Add your `https-proxy-cert.cert` and `https-proxy-cert.key` files in `.config/nginx` or `remove lines 11-12` in `docker-compose.production.yml` and `remove lines 44-50` in `.config/nginx/production.conf.template`.

### Mongo
* Configure Mongo (`$MONGO_HOST`, `$MONGO_PORT`, `$MONGO_ROOT_DIR`, `$MONGO_LOG_DIR`, `$MONGO_ROOT_USERNAME` and `$MONGO_ROOT_PASSWORD` in the files below are automatically replaced by the values in `.env`)
  * Setup database initialization in `.config/mongo/mongo-init.js`.
  * Add custom [mongosh](https://www.mongodb.com/docs/mongodb-shell/) scripts  in `.config/mongo/.mongoshrc.js`.
  * Adapt `.config/mongo/development.mongod.conf` and `.config/mongo/production.mongod.conf`.

### Docker
* Build the Docker container
  * Build Docker container `docker-build.sh`.
* Start the Docker container
  * Start Docker container `docker-start.sh`.

### Nuxt3
* Access the Nuxt3 Docker container
  * Access the Nuxt3 Docker container `docker exec -it $NUXT_HOST bash` (replace `$NUXT_HOST` with `the value of NUXT_HOST` in `.env`).
* Install npm dependencies
  * Install npm dependencies `npm install`.
* Choose a [rendering mode](https://nuxt.com/docs/guide/concepts/rendering#rendering-modes)
  * Static Site Generation (SSG)
    * Configure Nuxt3
      * Set `ssr: false` in `nuxt/nuxt.config.ts`.
    * Render your site
      * [Build your site](https://nuxt.com/docs/api/commands/build#nuxi-build)
        * Run `npm run build`.
      * [Build your site and pre-render the routes](https://nuxt.com/docs/api/commands/generate#nuxi-generate)
        * Run `npm run generate`.
    * Preview your site
      * Run `npm run preview`.
  * Server Side Rendering (SSR)
    * Configure Nuxt3
      * Set `ssr: true` in `nuxt/nuxt.config.ts`.
    * Render your site
      * [Build your site](https://nuxt.com/docs/api/commands/build#nuxi-build)
        * Run `npm run build`.
      * [Build your site and pre-render the routes](https://nuxt.com/docs/api/commands/generate#nuxi-generate)
        * Run `npm run generate`.
    * Preview your site
      * Run `npm run start`.
* [Deploy your site](https://nuxt.com/docs/getting-started/deployment#deployment)
  * Set `APP_ENV=production` in `.env` and run `docker-restart.sh`.

## License
This project is licensed under the Apache-2.0 license, Copyright 2023 CINID. For more information see the [LICENSE](LICENSE) file.
