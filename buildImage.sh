#!/bin/bash

if [ -L "$0" ]; then 
  DIR="$(cd "$($(pwd)/$(readlink "$0"))" && pwd)"
else
  DIR="$(cd "$(dirname "$0")" && pwd)"
fi

cd $DIR

docker build --no-cache -t bitcoin-sv .

