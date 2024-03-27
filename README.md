# pvpgn-docker: Run a PvPGN Server with Docker

This repository provides a convenient way to set up and run a PvPGN server using Docker.

## Prerequisites

* Docker: [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/)

## Installation

There are two ways to install this project:

**1. Using Git:**
Use Git for version control and easier updates.

```bash
git clone https://github.com/jasenmichael/pvpgn-docker.git pvpgn
cd pvpgn
./install-pvpgn.sh
```


**2. Manual Download (Without Git):**
Download the installation script directly.
```bash
mkdir pvpgn
cd pvpgn
curl -fsSL https://raw.githubusercontent.com/jasenmichael/pvpgn-docker/main/install-pvpgn.sh -O
chmod +x install-pvpgn.sh
./install-pvpgn.sh
```

## Usage
```bash
./start-pvpgn.sh --help
```

```
  PvPGN Server Docker Installation Script
 To install the first time run:
    ./install-pvpgn.sh
  
  USAGE: ./install-pvpgn.sh [OPTIONS]
  --help, -h     Show this help message

  After first install, re-run this script with the following options:
  --fresh, -f    Remove the container and image, then rebuild
                 *makes a backup ./etc and ./var dirs
  --build, -b    Remove the container and image, then rebuild
                  *retains ./etc and ./var dirs
  NOTE: -f anf -b make it easy to customize the image (Dockerfile) and the container (entrypoint.sh)

  To stop the container, run:
    docker stop pvpgn-server
  To start the container, run:
    docker start pvpgn-server
  To remove the container, run:
    docker rm pvpgn-server
  
  --fresh and --build flags will:
     - remove the container and image,
     - then rebuild using the current Dockerfile and entrypoint.sh
   this makes it easy to customize the image (Dockerfile) and the container (entrypoint.sh)
  
  EXAMPLES:
  To do a fresh install (backup ./etc and ./var dirs), run:
    ./install-pvpgn.sh --fresh
  To re-build (retains ./etc and ./var dirs), run:
    ./install-pvpgn.sh --build
```

## Configuration
create a .env file in the root directory with any of the following variables you wish to override. 

these are default values loaded (even if there is no .env file):
```bash
CONTAINER_NAME=pvpgn-server
IMAGE_NAME=jasenmichael/pvpgn
WEB_PORT=3000
```
*you will probably only want to change the WEB_PORT value.