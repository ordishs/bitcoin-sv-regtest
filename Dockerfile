FROM ubuntu:22.04

RUN apt-get update

RUN apt-get -y install curl

RUN curl -OL https://download.bitcoinsv.io/bitcoinsv/1.0.13/bitcoin-sv-1.0.13-x86_64-linux-gnu.tar.gz

RUN tar zxvf bitcoin-sv-1.0.13-x86_64-linux-gnu.tar.gz

RUN ln -s /bitcoin-sv-1.0.13/bin/bitcoin-cli /bitcoin-cli

COPY bitcoin.conf /root/.bitcoin/bitcoin.conf

# rpc
EXPOSE 18332/tcp
# p2p
EXPOSE 18333/tcp

ENTRYPOINT ["/bitcoin-sv-1.0.13/bin/bitcoind", "-regtest",  "-printtoconsole"]
