#!/bin/bash

cat <<'eof' | docker build -t kernel-builder:latest -
FROM debian:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y zip unzip python3 python-is-python3 curl wget git rsync bison bc flex file vim pkgconf debhelper-compat kmod cpio libssl-dev libelf-dev build-essential crossbuild-essential-arm64 libncurses-dev && \
    apt-get clean
RUN echo 'echo -e "Kernel Builder by fossfrog\nTwitter: ShubhamVis98\nWeb: https://fossfrog.in\n"' >> /root/.bashrc
RUN echo 'echo -e "Kernel Builder by fossfrog\nTwitter: ShubhamVis98\nWeb: https://fossfrog.in\n"' > /etc/motd

CMD ["bash", "-l"]

eof
