#!/bin/sh
set -e

echo "Generating config.yml from config.template.yml"
mkdir -p /config
envsubst < /config.template.yml > /config/config.yml

echo "Starting Gatus..."
exec /gatus