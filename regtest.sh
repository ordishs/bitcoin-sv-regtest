#!/bin/bash

if [ "$1" == "" ]; then
  echo "Please specify 'start', 'stop' or other bitcoin-cli command"
  exit 1
fi

if [ "$1" == "stop" ]; then
  docker exec bitcoin-sv-regtest_n1 /bitcoin-cli stop
  docker exec bitcoin-sv-regtest_n2 /bitcoin-cli stop
  docker exec bitcoin-sv-regtest_n3 /bitcoin-cli stop
  exit 0
fi  

if [ "$1" == "start" ]; then

  mkdir -p $HOME/.keystore

  if [ ! -f "$HOME/.keystore/ps.key" ]; then
    echo "Creating $HOME/.keystore/ps.key..."
    echo "tprv8ZgxMBicQKsPfPCcKvAPAhga6QNeC1xPXhPBhFtw1CvRisZHnCF4LAjDbkcY7CwhndHrvTvmRWWwqRM9XzaAVRxwh81wnPV1kX8gU1XbEhx" > $HOME/.keystore/ps.key
  fi

  if [ -L "$0" ]; then
    DIR="$(cd "$($(pwd)/$(readlink "$0"))" && pwd)"
  else
    DIR="$(cd "$(dirname "$0")" && pwd)"
  fi

  for D in $DIR/regtest/n1 $DIR/regtest/n2 $DIR/regtest/n3
  do
    mkdir -p $D

    if [ ! -f "$D/bitcoin.conf" ]; then
      echo "Creating $D/bitcoin.conf..."
      cat << EOL > $D/bitcoin.conf
port=18333
rpcbind=0.0.0.0
rpcport=18332
rpcuser=bitcoin
rpcpassword=bitcoin
rpcallowip=0.0.0.0/0
dnsseed=0
listenonion=0
listen=1
server=1
regtest=1
debug=1
usecashaddr=0
txindex=1

EOL
    fi

  done

  mkdir -p $DIR/regtest/n1/regtest

  if [ ! -f "$DIR/regtest/n1/regtest/wallet.dat" ]; then
    echo "Creating $DIR/regtest/n1/regtest/wallet.dat..."
    cp regtest_wallet.dat $DIR/regtest/n1/regtest/wallet.dat
  fi

  IP=$(docker network inspect bridge --format='{{(index .IPAM.Config 0).Gateway}}')

  docker run --rm --name bitcoin-sv-regtest_n1 -p 18332:18332 -p 18333:18333 -p 28332:28332 --volume $DIR/regtest/n1:/root/.bitcoin -d -t bitcoin-sv -addnode=$IP:18501 -addnode=$IP:18502 -zmqpubhashblock=tcp://*:28332 -zmqpubhashtx=tcp://*:28332

  docker run --rm --name bitcoin-sv-regtest_n2 -p 18501:18333 --volume $DIR/regtest/n2:/root/.bitcoin -d -t bitcoin-sv -addnode=$IP:18333 -addnode=$IP:18502

  docker run --rm --name bitcoin-sv-regtest_n3 -p 18502:18333 --volume $DIR/regtest/n3:/root/.bitcoin -d -t bitcoin-sv -addnode=$IP:18333 -addnode=$IP:18501

else

  docker exec bitcoin-sv-regtest_n1 /bitcoin-cli $@

fi
