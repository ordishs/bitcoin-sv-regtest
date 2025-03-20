#!/bin/bash

if [ "$1" == "" ]; then
  echo "Please specify 'start', 'stop', 'build', 'clean' or other bitcoin-cli command"
  exit 1
fi

if [ -L "$0" ]; then 
  DIR="$(cd "$($(pwd)/$(readlink "$0"))" && pwd)"
else
  DIR="$(cd "$(dirname "$0")" && pwd)"
fi

# Build is commented out as we are using an official image from dockerhub

if [ "$1" == "build" ]; then
  cd $DIR
  cat <<EOF | docker build --no-cache -t bitcoin-sv -
ARG PLATFORM=linux/amd64
FROM --platform=\$PLATFORM ubuntu:20.04

RUN apt-get update && apt-get -y install curl libatomic1

RUN curl -OL https://download.bitcoinsv.io/bitcoinsv/1.0.16/bitcoin-sv-1.0.16-x86_64-linux-gnu.tar.gz

RUN tar zxvf bitcoin-sv-1.0.16-x86_64-linux-gnu.tar.gz

RUN ln -s /bitcoin-sv-1.0.16/bin/bitcoin-cli /bitcoin-cli
RUN ln -s /bitcoin-sv-1.0.16/bin/bitcoind /bitcoind

RUN echo '#!/bin/sh' > /root/entrypoint.sh && echo '/bitcoind -datadir=/data \$@' >> /root/entrypoint.sh 
RUN chmod +x /root/entrypoint.sh

ENTRYPOINT ["/root/entrypoint.sh"]
EOF
  exit $?
fi

if [ "$1" == "clean" ]; then
  if $(docker ps -a | grep -q bitcoin-sv-regtest); then
    echo "bitcoin-sv-regtest container is running, stop before cleaning."
    exit 1
  fi

  rm -rf $DIR/data
  exit 0
fi

if [ "$1" == "stop" ]; then
  docker exec bitcoin-sv-regtest /bitcoin-cli stop
  exit 0
fi

if [ "$1" == "start" ]; then
  mkdir -p $DIR/data

  if [ -f regtest_wallet.dat ] && [ ! -f "$DIR/data/wallet.dat" ]; then
    # privkey is "tprv8ZgxMBicQKsPfPCcKvAPAhga6QNeC1xPXhPBhFtw1CvRisZHnCF4LAjDbkcY7CwhndHrvTvmRWWwqRM9XzaAVRxwh81wnPV1kX8gU1XbEhx"  
    echo "Creating $DIR/data/wallet.dat..."
    cp regtest_wallet.dat $DIR/data/wallet.dat
  fi

  if [ ! -f "$DIR/data/bitcoin.conf" ]; then
    echo "Creating $DIR/data/bitcoin.conf..."

    cat << EOL > $DIR/data/bitcoin.conf
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
rest=1
regtest=1
debug=1
usecashaddr=0
txindex=1
excessiveblocksize=1000000000
maxstackmemoryusageconsensus=100000000
genesisactivationheight=1
zmqpubhashblock=tcp://*:28332
zmqpubhashtx=tcp://*:28332
zmqpubdiscardedfrommempool=tcp://*:28332
zmqpubremovedfrommempoolblock=tcp://*:28332

zmqpubinvalidtx=tcp://*:28332
invalidtxsink=ZMQ
minminingtxfee=0
EOL
  fi

  # IMAGE_NAME=bitcoin-sv # LOCAL BUILD
  IMAGE_NAME=bitcoinsv/bitcoin-sv # OFFICIAL IMAGE

  docker run --platform linux/amd64 \
    -d \
    --rm \
    --name bitcoin-sv-regtest \
    -p 18332:18332 -p 18333:18333 -p 28332:28332 \
    --volume $DIR/data:/data \
    -e BITCOIN_RPC_USER=bitcoin \
    -e BITCOIN_RPC_PASSWORD=bitcoin \
    $IMAGE_NAME bitcoind -datadir=/data -regtest -debug=1 -standalone

  exit $?

else

  docker exec bitcoin-sv-regtest bitcoin-cli -datadir=/data $@

fi
