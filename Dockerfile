FROM ubuntu:18.04

RUN apt-get update

RUN apt-get -y install curl

RUN curl -OL https://download.bitcoinsv.io/bitcoinsv/0.2.1/bitcoin-sv-0.2.1-x86_64-linux-gnu.tar.gz

RUN tar zxvf bitcoin-sv-0.2.1-x86_64-linux-gnu.tar.gz

RUN ln -s /bitcoin-sv-0.2.1/bin/bitcoin-cli /bitcoin-cli

COPY entrypoint.sh /root

ENTRYPOINT ["/root/entrypoint.sh"]
