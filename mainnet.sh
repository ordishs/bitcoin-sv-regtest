#!/bin/bash

if [ "$1" == "start" ]; then

if [ -L "$0" ]; then 
  DIR="$(cd "$($(pwd)/$(readlink "$0"))" && pwd)"
else
  DIR="$(cd "$(dirname "$0")" && pwd)"
fi

mkdir -p $DIR/mainnet


if [ ! -f $DIR/mainnet/bitcoin.conf ]; then
  echo "Creating $DIR/mainnet/bitcoin.conf..."
  cat << EOL > $DIR/mainnet/bitcoin.conf
port=8333
rpcbind=0.0.0.0
rpcport=8332
rpcuser=bitcoin
rpcpassword=bitcoin
rpcallowip=0.0.0.0/0
dnsseed=0
listenonion=0
listen=1
server=1
debug=1
usecashaddr=0
txindex=1
EOL
fi

docker run --rm --name bitcoin-sv-mainnet -p 8332:8332 -p 8333:8333 -p 28332:28332 --volume $DIR/mainnet:/root/.bitcoin -d -t bitcoin-sv

else

docker exec bitcoin-sv-mainnet /bitcoin-cli -rpcuser=bitcoin -rpcpassword=bitcoin $@

fi
