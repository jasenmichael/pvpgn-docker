#!/bin/bash
cd "$(dirname "$0")" || exit

git pull

# check if --branch or -b flag is passed
if [ "$1" == "--branch" ]; then
  git checkout "$2"
fi

./install.sh -b
