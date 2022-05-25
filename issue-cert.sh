#!/bin/bash
set -o errexit -o pipefail -o noclobber -o nounset

# See https://stackoverflow.com/a/29754866/1391518 for usage of getopt in
# this script
! getopt --test > /dev/null 
if [ ${PIPESTATUS[0]} -ne 4 ]; then
  echo 'getopt (in util-linux deb package) is needed to run this script.'
  exit 1
fi

usage() {
  >&2 cat <<EOF
Usage: $0 [--ip address] [--days days] [--org organizationName] [--data dataDir] server_fqdn
EOF
  exit 2
}

LONGOPTS=ip:,data:,days:,org:
OPTIONS=

! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [ ${PIPESTATUS[0]} -ne 0 ]; then
  usage
fi
eval set -- "$PARSED"

data_dir=./my-root-ca-data
server_ipaddr=""
org_name=internal
days=365
while true; do
  case "$1" in
  --data)
    data_dir="$2"
    shift 2
    ;;
  --days)
    days="$2"
    shift 2
    ;;
  --ip)
    server_ipaddr="$2"
    shift 2
    ;;
  --org)
    org_name="$2"
    shift 2
    ;;
  --)
    shift
    break
    ;;
  *)
    echo "Programming error"
    exit 3
    ;;
  esac
done
if [ $# -ne 1 ]; then
  usage
fi

server_fqdn="$1"

cd "$data_dir"

key_file="private/$server_fqdn.key"
csr_file="./$server_fqdn.csr"
ext_file="./$server_fqdn.ext"
cert_file="certs/$server_fqdn.crt"

openssl genpkey -out "$key_file" -algorithm ED25519

openssl req -new -config my-root-ca.conf -key "$key_file" -days "$days" -subj "/C=JP/O=$org_name/CN=$server_fqdn" -out "$csr_file"

if [ -n "$server_ipaddr" ]; then
  subject_alt_name="DNS:$server_fqdn, IP:$server_ipaddr"
else
  subject_alt_name="DNS:$server_fqdn"
fi

cat <<EOF > "$ext_file"
authorityKeyIdentifier = keyid:always
basicConstraints = critical,CA:false
extendedKeyUsage = clientAuth,serverAuth
keyUsage = critical,digitalSignature,keyEncipherment
subjectKeyIdentifier = hash
subjectAltName = $subject_alt_name
EOF

openssl ca -batch -config my-root-ca.conf -in "$csr_file" -notext -out "$cert_file" -extfile "$ext_file"

rm "$csr_file" "$ext_file"

echo "generated key $key_file and certificate $cert_file"
