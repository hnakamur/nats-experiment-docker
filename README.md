nats-experiment-docker
======================

A docker-compose config for experimenting with a [NATS](https://nats.io/) JetStream cluster.

## How to try JetStream in a cluster

Arranged version of [JetStream Walkthrough - NATS Docs](https://docs.nats.io/nats-concepts/jetstream/js_walkthrough).

The following step uses 2 terminals:

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
nats --server https://node1:4222 --tlsca /usr/local/etc/my-root-ca.crt stream add my_stream \
  --subjects=foo --storage=file --retention=limits --discard=old --max-msgs=-1 \
  --max-msgs-per-subject=-1 \
  --max-bytes=-1 --max-age=-1 --max-msg-size=-1 --dupe-window=2m \
  --no-allow-rollup --no-deny-delete --no-deny-purge \
  --replicas=3
```

```
nats --server https://node1:4222 --tlsca /usr/local/etc/my-root-ca.crt pub foo --count=1000 --sleep 1s "publication #{{Count}} @ {{TimeStamp}}"
```


Run the following commands at terminal #2:

```
docker compose exec node2 bash
```

```
nats --server https://node1:4222 --tlsca /usr/local/etc/my-root-ca.crt consumer add my_stream pull_consumer --pull --deliver all --ack explicit --replay instant --filter='' --max-deliver=-1 --max-pending=0 --no-headers-only --backoff=linear
```

```
nats --server https://node1:4222 --tlsca /usr/local/etc/my-root-ca.crt consumer next my_stream pull_consumer --count 1000 
```

```
nats --server https://node1:4222 --tlsca /usr/local/etc/my-root-ca.crt consumer rm my_stream pull_consumer --force
```

```
nats --server https://node1:4222 --tlsca /usr/local/etc/my-root-ca.crt consumer ls my_stream
```

Run the following commands at terminal #1:

```
nats --server https://node1:4222 --tlsca /usr/local/etc/my-root-ca.crt stream purge my_stream --force
```

```
nats --server https://node1:4222 --tlsca /usr/local/etc/my-root-ca.crt stream rm my_stream --force
```

```
nats --server https://node1:4222 --tlsca /usr/local/etc/my-root-ca.crt stream ls
```
