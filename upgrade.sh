#!/bin/bash
cd "$(dirname "$0")" || exit

git pull

./install.sh -b
