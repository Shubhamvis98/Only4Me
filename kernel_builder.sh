
cat <<'eof' | docker build -t kernelbuilder:latest -
FROM debian

ENV DEBIAN_FRONTEND noninteractive

RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt upgrade -y

RUN apt install -y wget bzip2 build-essential libncurses-dev cpio file git vim bsdextrautils kmod flex bison bc libelf-dev libssl-dev gcc-aarch64-linux-gnu zip python3 python-is-python3

CMD ["/bin/bash", "-l"]
eof
