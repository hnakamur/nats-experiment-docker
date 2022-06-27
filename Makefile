NODE_CERTS = my-root-ca-data/certs/node1.crt \
             my-root-ca-data/certs/node2.crt \
             my-root-ca-data/certs/node3.crt

up: build_image $(NODE_CERTS)
	docker compose up -d

my-root-ca-data/certs/node1.crt: my-root-ca-data/my-root-ca.crt
	./issue-cert.sh --days 1 node1

my-root-ca-data/certs/node2.crt: my-root-ca-data/my-root-ca.crt
	./issue-cert.sh --days 1 node2

my-root-ca-data/certs/node3.crt: my-root-ca-data/my-root-ca.crt
	./issue-cert.sh --days 1 node3

my-root-ca-data/my-root-ca.crt:
	./setup-my-root-ca.sh --days 1 'My root CA'

build_image:
	DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker build -t local/nats .
