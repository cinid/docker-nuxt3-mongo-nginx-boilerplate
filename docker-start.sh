#!/bin/bash

APP_ENV=$(grep -v '^#' .env | grep APP_ENV | cut -d'=' -f2)

if [ $APP_ENV == "production" ]; then
    echo "Starting Docker in production environment"
    docker-compose -f docker-compose.yml -f docker-compose.production.yml up -d
else
    echo "Starting Docker in development environment"
    docker-compose -f docker-compose.yml up -d
fi
