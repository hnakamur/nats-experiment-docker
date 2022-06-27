nats-experiment-docker
======================

A docker-compose config for experimenting with a [NATS](https://nats.io/) JetStream cluster.

## How to try JetStream in a cluster

Arranged version of [JetStream Walkthrough - NATS Docs](https://docs.nats.io/nats-concepts/jetstream/js_walkthrough).

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
export NATS_URL=https://node1:4222,https://node2:4222,https://node3:4222
export NATS_CA=/usr/local/etc/my-root-ca.crt
```

```
nats stream add my_stream \
  --subjects=foo --storage=file --retention=limits --discard=old --max-msgs=-1 \
  --max-msgs-per-subject=-1 \
  --max-bytes=-1 --max-age=-1 --max-msg-size=-1 --dupe-window=2m \
  --no-allow-rollup --no-deny-delete --no-deny-purge \
  --replicas=3
```

```
nats pub foo --count=1000 --sleep 1s "publication #{{Count}} @ {{TimeStamp}}"
```


Run the following commands at terminal #5:

```
docker compose exec node2 bash
```

```
export NATS_URL=https://node1:4222,https://node2:4222,https://node3:4222
export NATS_CA=/usr/local/etc/my-root-ca.crt
```

```
nats consumer add my_stream pull_consumer --pull --deliver all --ack explicit --replay instant --filter='' --max-deliver=-1 --max-pending=0 --no-headers-only --backoff=linear
```

```
nats consumer next my_stream pull_consumer --count 1000
```

```
nats consumer rm my_stream pull_consumer --force
```

```
nats consumer ls my_stream
```

Run the following commands at terminal #4:

```
nats stream purge my_stream --force
```

```
nats stream rm my_stream --force
```

```
nats stream ls
```

## Stop the docker compose

```
docker compose rm --stop --force
```
