#!/bin/sh

# Create initial directories and files for home automation stack.

BASE_DIR=$(pwd)
ESPHOME_DIR=$BASE_DIR/esphome
HASS_DIR=$BASE_DIR/hass
MOSQUITTO_DIR=$BASE_DIR/mosquitto
NGINX_DIR=$BASE_DIR/nginx

echo "Creating directory structure."
install -d -o0 -g0 -m755 $ESPHOME_DIR/config
install -d -o0 -g0 -m755 $HASS_DIR/config
install -d -o1883 -g1883 -m755 $MOSQUITTO_DIR/config
install -d -o1883 -g1883 -m755 $MOSQUITTO_DIR/data
install -d -o1883 -g1883 -m755 $MOSQUITTO_DIR/log
install -d -o0 -g0 -m755 $NGINX_DIR/conf.d
install -d -o0 -g0 -m755 $NGINX_DIR/html

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

  mosquitto:
    container_name: mosquitto
    hostname: mosquitto
    image: eclipse-mosquitto:latest
    ports:
      - 1883:1883
      - 9001:9001
    volumes:
      - $MOSQUITTO_DIR/config:/mosquitto/config
      - $MOSQUITTO_DIR/data:/mosquitto/data
      - $MOSQUITTO_DIR/log:/mosquitto/log
    stdin_open: true
    tty: true
    restart: unless-stopped

  nginx:
    container_name: nginx_hass
    hostname: nginx
    image: nginx
    ports:
      - 8080:80
      - 8443:443
    volumes:
      - /etc/ssl:/etc/ssl:ro
      - $NGINX_DIR/conf.d:/etc/nginx/conf.d
      - $NGINX_DIR/html:/usr/share/nginx/html:ro
    networks:
      reverse_proxy:
        ipv4_address: 172.16.0.2
    restart: unless-stopped

networks:
  reverse_proxy:
    driver: bridge
    ipam:
      config:
        - subnet: 192.168.255.0/24
          gateway: 192.168.255.1
EOF

echo "Creating mosquitto.conf."
cat <<EOF >$MOSQUITTO_DIR/config/mosquitto.conf
listener 1883
listener 9001
protocol websockets
persistence true
persistence_file mosquitto.db
persistence_location /mosquitto/data

#Authentication
allow_anonymous true
password_file /mosquitto/config/passwd
EOF
chown 1883:1883 $MOSQUITTO_DIR/config/mosquitto.conf
chmod 700 $MOSQUITTO_DIR/config/mosquitto.conf

echo "Creating empty mosquitto password file."
touch $MOSQUITTO_DIR/config/passwd
chown 1883:1883 $MOSQUITTO_DIR/config/passwd
chmod 700 $MOSQUITTO_DIR/config/passwd

echo
echo "To start home automation stack, use: docker-compose up -d"
echo
echo "To add mosquitto MQTT users and passwords:
echo "docker exec -it mosquitto sh"
echo "/usr/bin/mosquitto_passwd -b /mosquitto/config/pwfile mqttuser mqttpassword"
