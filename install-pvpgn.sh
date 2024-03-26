#!/bin/bash

cd "$(dirname "$0")" || exit

container_id=""
container_name="pvpgn-server"

# SETUP FILES (copy files from container to host)
if [ ! -d "./var" ] || [ ! -d "./etc" ]; then
  container_id=$(docker run --rm -d wwmoraes/pvpgn-server)

  if [ ! -d "./var" ]; then
    echo "./var directory not found, copying now..."
    docker cp "$container_id":/usr/local/pvpgn/var/pvpgn ./var
  fi

  if [ ! -d "./etc" ]; then
    echo "./etc directory not found, copying now..."
    docker cp "$container_id":/usr/local/pvpgn/etc/pvpgn ./etc
  fi

  docker stop "$container_id"
fi


# chmod +x entrypoint.sh
chmod -R 777 ./var >/dev/null 2>&1
chmod -R 777 ./etc >/dev/null 2>&1

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
   -v "$PWD"/var:/usr/local/pvpgn/var/pvpgn:rw \
   -v "$PWD"/etc:/usr/local/pvpgn/etc/pvpgn:rw \
   wwmoraes/pvpgn-server)

   docker update --restart unless-stopped pvpgn-server
   echo "Container pvpgn-server created with id $container_id"
   echo "pvpgn-server started"
fi

echo " To stop it, run: docker stop pvpgn-server"
echo " To restart it, run: docker start pvpgn-server"
echo " To remove it run: docker rm pvpgn-server"


