#!/bin/bash

# image_name="jasenmichael/pvpgn"
container_name="pvpgn-server"

cd "$(dirname "$0")" || exit

# check if docker is installed
if ! command -v docker &> /dev/null; then
  echo "Docker is not installed, please install it first"
  echo "https://docs.docker.com/get-docker/"
  exit 1
fi

# check if entrypoint.sh exists
if [ ! -f "entrypoint.sh" ]; then
  echo '#!/bin/bash

/sbin/bnetd -f' > entrypoint.sh
  chmod +x entrypoint.sh
fi

# ensure the docker image "jasenmichael/pvpgn" exists locally
if [ "$(docker images -q jasenmichael/pvpgn 2> /dev/null)" == "" ]; then
  if [ ! -f "./Dockerfile" ]; then
    echo "Dockerfile not found in the current directory, checking docker registry..."
    docker pull jasenmichael/pvpgn 2> /dev/null || \
      echo "Docker image jasenmichael/pvpgn not found in the registry"
      echo "Downloading and building Dockerfile from the repository..."
      curl -fsSL https://raw.githubusercontent.com/jasenmichael/pvpgn-docker/dev/Dockerfile -O && \
      docker build . -t jasenmichael/pvpgn
  else
    echo "Docker image jasenmichael/pvpgn does not exist, building it from Dockerfile..."
    docker build . -t jasenmichael/pvpgn
  fi
fi

if [ "$(docker images -q jasenmichael/pvpgn 2> /dev/null)" == "" ]; then
  echo "Docker image jasenmichael/pvpgn still not found, exiting..."
  exit 1
fi

# SETUP FILES (copy files from container to host)
if [ ! -d "./var" ] || [ ! -d "./etc" ]; then
  container_id=$(docker run --rm -d --entrypoint="bnetd" jasenmichael/pvpgn bnetd -f)

  if [ ! -d "./var" ]; then
    echo "./var directory not found, copying now..."
    docker cp "$container_id":/var/pvpgn ./var
  fi

  if [ ! -d "./etc" ]; then
    echo "./etc directory not found, copying now..."
    docker cp "$container_id":/etc/pvpgn ./etc
  fi

  docker stop "$container_id"
fi

chmod -R 777 ./var &> /dev/null
chmod -R 777 ./etc &> /dev/null

# CREATE CONTAINER
# check if the container pvpgn-server exists
if [ "$(docker ps -q -a -f name=$container_name)" ]; then
  if [ "$(docker ps -q -f name=$container_name)" ]; then
    # container pvpgn-server is started, do nothing
    echo "pvpgn-server is already started"
  else
    # container pvpgn-server is not running, start it
    echo "pvpgn-server already exists, starting it"
    echo "$(docker start pvpgn-server) started"
  fi
# container does not exist, create it
else
  echo "Container pvpgn-server does not exist, creating it"
  container_id=$(docker run -d \
   --name pvpgn-server \
   -p 6112:6112/udp \
   -p 6112:6112/tcp \
   -p 4000:4000  \
   -v "$PWD"/var:/var/pvpgn:rw \
   -v "$PWD"/etc:/etc/pvpgn:rw \
   jasenmichael/pvpgn)

   docker update --restart unless-stopped pvpgn-server &> /dev/null || exit 1
   echo "Container pvpgn-server created with id $container_id"
   echo "pvpgn-server started"
fi

echo " To stop it, run: docker stop pvpgn-server"
echo " To restart it, run: docker start pvpgn-server"
echo " To remove it run: docker rm pvpgn-server"


