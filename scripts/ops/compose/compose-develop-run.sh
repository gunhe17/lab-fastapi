#!/bin/sh

APP_ENV=develop

# pre-run
APP_ENV=$APP_ENV sh scripts/ops/compose/pre/provision-secret.sh

# run
docker-compose -f .docker/docker-compose.develop.yml up -d

# post-run
sh scripts/ops/compose/post/deprovision-secret.sh