nats-experiment-docker
======================

A docker-compose config for experimenting with a [NATS](https://nats.io/) JetStream cluster.

## How to try key value store

Arranged version of [Key/Value Store Walkthrough - NATS Docs](https://docs.nats.io/nats-concepts/jetstream/key-value-store/kv_walkthrough).

The following step uses 4 terminals:

1. server at node1
2. server at node2
3. server at node3
4. client at node4

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
nats --server https://node1:4222 --tlsca /usr/local/etc/my-root-ca.crt kv add my_kv --replicas 3
```

```
nats --server https://node1:4222 --tlsca /usr/local/etc/my-root-ca.crt kv put my_kv Key1 Value1
```

```
nats --server https://node1:4222 --tlsca /usr/local/etc/my-root-ca.crt kv get my_kv Key1
```

```
nats --server https://node2:4222 --tlsca /usr/local/etc/my-root-ca.crt kv get my_kv Key1
```

```
nats --server https://node3:4222 --tlsca /usr/local/etc/my-root-ca.crt kv get my_kv Key1
```

At terminal #1 press Ctrl-C to stop nats-server.

At terminal #4 run following commands:

```
nats --server https://node1:4222 --tlsca /usr/local/etc/my-root-ca.crt kv get my_kv Key1
```
(an error is expected)

```
nats --server https://node2:4222 --tlsca /usr/local/etc/my-root-ca.crt kv get my_kv Key1
```

```
nats --server https://node3:4222 --tlsca /usr/local/etc/my-root-ca.crt kv get my_kv Key1
```

```
nats --server https://node2:4222 --tlsca /usr/local/etc/my-root-ca.crt kv put my_kv Key2 Value2
```

```
nats --server https://node2:4222 --tlsca /usr/local/etc/my-root-ca.crt kv get my_kv Key2
```

```
nats --server https://node3:4222 --tlsca /usr/local/etc/my-root-ca.crt kv get my_kv Key2
```

At terminal #1 start nats-server again:

```
nats-server -config /usr/local/etc/nats-server.conf
```

At terminal #4 run following commands:

```
nats --server https://node1:4222 --tlsca /usr/local/etc/my-root-ca.crt kv get my_kv Key2
```
(it is expected to get `Value2`)

```
exit
```

```
docker compose rm --stop --force
```
