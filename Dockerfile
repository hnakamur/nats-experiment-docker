#syntax=docker/dockerfile:1.4
FROM ubuntu:22.04

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt <<EOR
  apt-get update
  apt-get install -y curl

  server_repo=https://github.com/nats-io/nats-server
  server_ver=$(curl -sS -w '%{redirect_url}' -o /dev/null "$server_repo/releases/latest" | sed 's|.*/tag/||')
  server_deb=/var/cache/apt/nats-server.deb
  curl -sSLo "$server_deb" "$server_repo/releases/download/$server_ver/nats-server-$server_ver-amd64.deb"

  cli_repo=https://github.com/nats-io/natscli
  cli_ver=$(curl -sS -w '%{redirect_url}' -o /dev/null "$cli_repo/releases/latest" | sed 's|.*/tag/v||')
  cli_deb=/var/cache/apt/nats.deb
  curl -sSLo "$cli_deb" "$cli_repo/releases/download/v$cli_ver/nats-$cli_ver-amd64.deb"

  apt-get install -y "$server_deb" "$cli_deb"
EOR

RUN <<EOR
  url_path=$(curl -s https://go.dev/dl/ | grep linux-amd64.tar.gz | head -1 | sed 's/.*href="//;s/">//')
  curl -L https://go.dev${url_path} | tar -zxf - -C /usr/local/
EOR

ENV EXAMPLE_VER=2c834d7d967f024348fbaa478eae18e9749431ba

RUN curl -L https://github.com/hnakamur/nats-stream-example/archive/${EXAMPLE_VER}.tar.gz | tar -zxf -
WORKDIR /nats-stream-example-${EXAMPLE_VER}
RUN /usr/local/go/bin/go build -o /usr/local/bin/nats-stream-example

WORKDIR /root
