#!/bin/sh

# Create initial directories and files for home automation stack.

BASE_DIR=$(pwd)
ESPHOME_DIR=$BASE_DIR/esphome
HASS_DIR=$BASE_DIR/hass

echo "Creating directory structure."
install -d -o0 -g0 -m755 $ESPHOME_DIR/config
install -d -o0 -g0 -m755 $HASS_DIR/config

echo "Creating compose.yml."
cat <<EOF >$BASE_DIR/compose.yml
services:
  esphome:
    container_name: esphome
    hostname: esphome
    image: esphome/esphome:latest
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
      - $ESPHOME_DIR/config:/config:rw
    network_mode: host
    restart: unless-stopped

  homeassistant:
    container_name: homeassistant
    image: ghcr.io/home-assistant/home-assistant:stable
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
      - $HASS_DIR/config:/config
    network_mode: host
    restart: unless-stopped
EOF

echo
echo "To start home automation stack, use: docker-compose up -d"
