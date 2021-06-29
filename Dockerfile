FROM ubuntu:18.04

RUN apt-get update

RUN apt-get -y install curl
RUN apt-get install libatomic1

RUN curl -OL https://download.bitcoinsv.io/bitcoinsv/1.0.8/bitcoin-sv-1.0.8-x86_64-linux-gnu.tar.gz

RUN tar zxvf bitcoin-sv-1.0.8-x86_64-linux-gnu.tar.gz

RUN ln -s /bitcoin-sv-1.0.8/bin/bitcoin-cli /bitcoin-cli
RUN ln -s /bitcoin-sv-1.0.8/bin/bitcoind /bitcoind

COPY entrypoint.sh /root

ENTRYPOINT ["/root/entrypoint.sh"]
