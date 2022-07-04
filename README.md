nats-experiment-docker
======================

A docker-compose config for experimenting with a [NATS](https://nats.io/) JetStream cluster.

## How to try JetStream in a cluster

Arranged version of [JetStream Walkthrough - NATS Docs](https://docs.nats.io/nats-concepts/jetstream/js_walkthrough).

Using [hnakamur/nats-stream-example](https://github.com/hnakamur/nats-stream-example) instead of [nats-io/natscli: The NATS Command Line Interface](https://github.com/nats-io/natscli).

The following step uses 5 terminals:

1. client1 at node1
2. client2 at node2

Run following command to build local docker image and start docker compose processes.

```
make
```

Run the following commands at terminal #1:

```
docker compose exec node1 bash
```

```
nats-server -config /usr/local/etc/nats-server.conf
```

Run the following commands at terminal #2:

```
docker compose exec node2 bash
```

```
nats-server -config /usr/local/etc/nats-server.conf
```

Run the following commands at terminal #3:

```
docker compose exec node3 bash
```

```
nats-server -config /usr/local/etc/nats-server.conf
```

Run the following commands at terminal #4:

```
docker compose exec node1 bash
```

```
nats-stream-example stream-add --stream my_stream2 --subject foo2 --replicas 3
```

```
nats-stream-example publish --subject foo2 --count 100
```


Run the following commands at terminal #5:

```
docker compose exec node2 bash
```

```
nats-stream-example consumer-add --consumer pull_consumer2 --stream my_stream2
```

```
nats-stream-example consumer-next --stream my_stream2 --consumer pull_consumer2 --count 100
```

## Stop the docker compose

```
docker compose rm --stop --force
```
