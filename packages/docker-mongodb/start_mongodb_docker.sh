#!/usr/bin/env bash
set -o errexit

# change to script's directory
cd "$(dirname "$0")"

# sourcing variable from config file
source ./config.file

# override config if there are any local config changes
if [ -f "./config.file.local" ]; then
  source ./config.file.local
fi

# docker did not stop properly
if [ "$(docker ps -q -f status=exited -f name=^$MONGODB_CONTAINER_NAME$)" ]; then
  docker rm $MONGODB_CONTAINER_NAME
fi

# check if mongodb container is running
if [ ! "$(docker ps -q -f name=^$MONGODB_CONTAINER_NAME$)" ]; then
  # check if the volume exists 
  if [ ! "$(docker volume ls --format '{{.Name}}' -f name=^$MONGODB_VOLUME_NAME$)" ]; then
    # create volume
    docker volume create --name=$MONGODB_VOLUME_NAME
  fi
  docker run -d -p $MONGODB_PORT:$MONGODB_PORT --name $MONGODB_CONTAINER_NAME -v $MONGODB_VOLUME_NAME:/data/db mongo --port $MONGODB_PORT
else
  echo "docker already running"
fi
