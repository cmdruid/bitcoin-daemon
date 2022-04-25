FROM debian:bullseye-slim

## Install dependencies.
RUN apt-get update && apt-get install -y \
  libevent-dev man openssl procps unzip xxd

RUN mkdir -p \
  /data/tor /var/lib/tor /var/log/bitcoin /var/log/tor

## Copy binaries from specified path.
COPY build/out/* /tmp/bin/

WORKDIR /tmp

## Unpack and install binaries, then clean up files.
RUN for file in /tmp/bin/*; do \
  if [ ! -z "$(echo $file | grep .tar.)" ]; then \
    echo "Unpacking $file to /usr ..." \
    && tar --wildcards --strip-components=1 -C /usr -xf $file \
  ; else \
    echo "Moving $file to /usr/bin ..." \
    && chmod +x $file && mv $file /usr/bin/ \
  ; fi \
; done

## Remove temporary files.
RUN rm -rf /tmp/* /var/tmp/*

## Uncomment this if you also want to wipe all repository lists.
#RUN rm -rf /var/lib/apt/lists/*

## Check bitcoind is installed.
RUN bitcoind -version | grep "Bitcoin Core version"

## Copy configuration files.
COPY config/torrc /etc/tor/
COPY config/bitcoin.conf /root/.bitcoin/

## Configure user account for Tor.
RUN addgroup tor \
  && adduser --system --no-create-home tor \
  && adduser tor tor \
  && chown -R tor:tor /data/tor /var/lib/tor /var/log/tor

## Setup entrypoint for image.
COPY run /root/run
RUN chmod +x /root/run/*

WORKDIR /root

ENTRYPOINT [ "/root/run/entrypoint.sh" ]
