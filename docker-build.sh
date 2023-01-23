#!/bin/bash

docker-compose build --no-cache mongo && docker-compose build nuxt
