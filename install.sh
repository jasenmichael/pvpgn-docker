#!/bin/bash

cd "$(dirname "$0")" || exit
# load .env file if exists
if [ -f ".env" ]; then
  export $(cat .env | awk -F= '{print "export ENV_"$1"="$2}')
fi

# VARIABLES
WORKING_DIR=$(pwd)
CONTAINER_NAME=${ENV_CONTAINER_NAME:-"pvpgn-server"}
IMAGE_NAME=${ENV_IMAGE_NAME:-"jasenmichael/pvpgn"}
WEB_PORT=${ENV_WEB_PORT:-3002}

DOCKER_RUN_COMMAND="docker run -d \
  --name $CONTAINER_NAME \
  -p 6112:6112/udp \
  -p 6112:6112/tcp \
  -p 4000:4000  \
  -p $WEB_PORT:3002  \
  -v $WORKING_DIR/var:/var/pvpgn:rw \
  -v $WORKING_DIR/etc:/etc/pvpgn:rw \
  --network host \
  $IMAGE_NAME"
  # -v $WORKING_DIR/web:/usr/local/pvpgn/web:rw \

###############################################################
usage(){
  echo " To install the first time run:
    $0
  
  USAGE: $0 [OPTIONS]
  --help, -h     Show this help message

  After first install, re-run this script with the following options:
  --fresh, -f    Remove the container and image, then rebuild
                 *makes a backup ./etc and ./var dirs
  --build, -b    Remove the container and image, then rebuild
                  *retains ./etc and ./var dirs
  NOTE: -f anf -b make it easy to customize the image (Dockerfile) and the container (entrypoint.sh)

  To stop the container, run:
    docker stop $CONTAINER_NAME
  To start the container, run:
    docker start $CONTAINER_NAME
  To remove the container, run:
    docker rm $CONTAINER_NAME
  
  --fresh and --build flags will:
     - remove the container and image,
     - then rebuild using the current Dockerfile and entrypoint.sh
   this makes it easy to customize the image (Dockerfile) and the container (entrypoint.sh)
  
  EXAMPLES:
  To do a fresh install (backup ./etc and ./var dirs), run:
    $0 --fresh
  To re-build (retains ./etc and ./var dirs), run:
    $0 --build"
}

# check --help or -h passed
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  usage
  exit 0
fi
###############################################################

# check if docker is installed
if ! command -v docker &> /dev/null; then
  echo "Docker is not installed, please install it first"
  echo "https://docs.docker.com/get-docker/"
  exit 1
fi

remove_container_and_image() {
  docker stop "$CONTAINER_NAME" &> /dev/null
  docker rm  "$CONTAINER_NAME" &> /dev/null
  docker rmi "$IMAGE_NAME" &> /dev/null
}

# check if --fresh flag is passed
if [ "$1" == "--fresh" ] || [ "$1" == "-f" ]; then
  echo "Removing existing $CONTAINER_NAME container and image..."
  remove_container_and_image
  mv ./var ./var-bak &> /dev/null
  mv ./etc ./etc-bak &> /dev/null
fi

# check if --build or -b flag is passed
if [ "$1" == "--build" ] || [ "$1" == "-b" ]; then
  echo "Building Docker image $IMAGE_NAME..."
  remove_container_and_image
fi

# check if entrypoint.sh exists
if [ ! -f "entrypoint.sh" ]; then
  echo '#!/bin/bash

pm2 start /usr/local/pvpgn/web/ecosystem.config.json

/sbin/bnetd -f' > entrypoint.sh
  chmod +x entrypoint.sh
fi

# ensure the docker image "$IMAGE_NAME" exists locally
if [ "$(docker images -q "$IMAGE_NAME" 2> /dev/null)" == "" ]; then

  if [ ! -f "./Dockerfile" ]; then
    echo "Dockerfile not found in the current directory, checking docker registry..."
    docker pull "$IMAGE_NAME" 2> /dev/null || \
      echo "Docker image $IMAGE_NAME not found in the registry"
      echo "Downloading and building Dockerfile from the repository..."
      curl -fsSL https://raw.githubusercontent.com/jasenmichael/pvpgn-docker/main/Dockerfile -O && \
      # build_web_and_image
      docker build . -t "$IMAGE_NAME"

  else
    echo "Docker image $IMAGE_NAME does not exist, building it from Dockerfile..."
    # build_web_and_image
    docker build . -t "$IMAGE_NAME"

  fi
fi

if [ "$(docker images -q "$IMAGE_NAME" 2> /dev/null)" == "" ]; then
  echo "Docker image $IMAGE_NAME still not found, exiting..."
  exit 1
fi

# SETUP FILES (copy files from container to host)
if [ ! -d "./var" ] || [ ! -d "./etc" ]; then
  CONTAINER_ID=$(docker run --rm -d --entrypoint="bnetd" "$IMAGE_NAME" bnetd -f)

  if [ ! -d "./var" ]; then
    echo "./var directory not found, copying now..."
    docker cp "$CONTAINER_ID":/var/pvpgn ./var
  fi

  if [ ! -d "./etc" ]; then
    echo "./etc directory not found, copying now..."
    docker cp "$CONTAINER_ID":/etc/pvpgn ./etc
  fi

  docker stop "$CONTAINER_ID"
fi

chmod -R 777 ./var &> /dev/null
chmod -R 777 ./etc &> /dev/null

# CREATE AND START CONTAINER
# check if the container "$CONTAINER_NAME" exists
if [ "$(docker ps -q -a -f name=$CONTAINER_NAME)" ]; then
  if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    # "$CONTAINER_NAME" is started, do nothing
    echo "$CONTAINER_NAME is already started"
  else
    # "$CONTAINER_NAME" is not running, start it
    echo "$CONTAINER_NAME already exists, starting it"
    echo "$(docker start "$CONTAINER_NAME") started"
  fi
# "$CONTAINER_NAME" does not exist, create it
else
  echo "Container $CONTAINER_NAME does not exist, creating it"
  CONTAINER_ID=$($DOCKER_RUN_COMMAND)

  docker update --restart unless-stopped "$CONTAINER_NAME" &> /dev/null || exit 1
  echo "Container $CONTAINER_NAME created with id $CONTAINER_ID"
  echo "$CONTAINER_NAME started"
fi

echo "for usage run:
  $0 -h"



