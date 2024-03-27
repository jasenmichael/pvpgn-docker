# pvpgn-docker: Run a PvPGN Server with Docker

This repository provides a convenient way to set up and run a PvPGN server using Docker.

## Prerequisites

* Docker: [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/)

## Installation

There are two ways to install this project:

**1. Using Git (Recommended):**

This method leverages Git for version control and easier updates.

```bash
git clone https://github.com/jasenmichael/pvpgn-docker.git pvpgn
cd pvpgn
./install-pvpgn.sh
```


**2. Manual Download (Without Git):**
If you don't prefer Git, you can download the installation script directly.
```bash
mkdir pvpgn
cd pvpgn
curl -fsSL https://raw.githubusercontent.com/jasenmichael/pvpgn-docker/main/install-pvpgn.sh -O
chmod +x install-pvpgn.sh
./install-pvpgn.sh
```