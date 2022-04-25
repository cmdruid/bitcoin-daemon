#!/bin/sh
## Startup script for docker container.

set -e

###############################################################################
# Environment
###############################################################################

NAME="bitcoin-daemon"

###############################################################################
# Methods
###############################################################################

build_image() {
  echo "Building $NAME from dockerfile ..."
  docker build --tag $NAME .
}

stop_container() {
  ## Check if previous container exists, and remove it.
  if docker container ls -a | grep $NAME > /dev/null 2>&1; then
    echo "Stopping current container..."
    docker container stop $NAME > /dev/null 2>&1
    docker container rm $NAME > /dev/null 2>&1
  fi
}

###############################################################################
# Script
###############################################################################

## Create build/out path if missing.
if [ ! -d "build/out" ]; then mkdir -p build/out; fi

## Check if tor binary is present.
if [ -z "$(ls build/out | grep tor)" ]; then
  echo "Tor binary is missing from build/out, rebuilding..."
  ./build/build.sh build/files/tor.dockerfile
fi

## Check if bitcoind binary is present.
if [ -z "$(ls build/out | grep bitcoind)" ]; then
  echo "Bitcoin binary is missing from build/out, rebuilding..."
  ./build/build.sh build/files/bitcoind.dockerfile
fi

## If existing image is not present, build it.
if [ -z "$(docker image ls | grep $NAME)" ] || [ "$1" = "--build" ]; then
  build_image
elif [ "$1" = "--rebuild" ]; then
  docker image rm $NAME > /dev/null 2>&1
  build_image
fi

## Make sure to stop any existing container.
stop_container

## Start docker container.
echo "Starting container for $NAME ... "

docker run -d \
  --name $NAME \
  --hostname $NAME \
  --mount type=volume,source=$NAME-data,target=/data \
  --mount type=bind,source=$(pwd)/snapshot,target=/snapshot \
  --restart unless-stopped \
$NAME:latest

## Start tailing logs for container.
docker logs -f $NAME