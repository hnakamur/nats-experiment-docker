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
Usage: $0 [--org organizationName] [--data dataDir] [--days days] ca_common_nane
EOF
  exit 2
}

LONGOPTS=org:,data:,days:
OPTIONS=

! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [ ${PIPESTATUS[0]} -ne 0 ]; then
  usage
fi
eval set -- "$PARSED"

data_dir=./my-root-ca-data
org_name=internal
default_days=3650
while true; do
  case "$1" in
  --org)
    org_name="$2"
    shift 2
    ;;
  --data)
    data_dir="$2"
    shift 2
    ;;
  --days)
    default_days="$2"
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

ca_common_name="$1"

if [ ! -d "$data_dir" ]; then
  mkdir -p "$data_dir"
  cd "$data_dir"
fi

if [ ! -f my-root-ca.conf ]; then
  cat <<EOF > my-root-ca.conf
[default]
name                    = my-root-ca
domain_suffix           =
default_ca              = ca_default
name_opt                = utf8,esc_ctrl,multiline,lname,align

[ca_dn]
countryName             = "JP"
organizationName        = "$org_name"
commonName              = "$ca_common_name"

[ca_default]
home                    = .
database                = \$home/db/index
serial                  = \$home/db/serial
crlnumber               = \$home/db/crlnumber
certificate             = \$home/\$name.crt
private_key             = \$home/private/\$name.key
RANDFILE                = \$home/private/random
new_certs_dir           = \$home/certs
unique_subject          = no
copy_extensions         = none
default_days            = $default_days
default_crl_days        = 365
default_md              = sha256
policy                  = policy_c_o_match

[policy_c_o_match]
countryName             = match
stateOrProvinceName     = optional
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[req]
default_bits            = 4096
encrypt_key             = yes
default_md              = sha256
utf8                    = yes
string_mask             = utf8only
prompt                  = no
distinguished_name      = ca_dn
req_extensions          = ca_ext

[ca_ext]
basicConstraints        = critical,CA:true
keyUsage                = critical,keyCertSign,cRLSign
subjectKeyIdentifier    = hash

[server_ext]
authorityInfoAccess     = @issuer_info
authorityKeyIdentifier  = keyid:always
basicConstraints        = critical,CA:false
crlDistributionPoints   = @crl_info
extendedKeyUsage        = clientAuth,serverAuth
keyUsage                = critical,digitalSignature,keyEncipherment
subjectKeyIdentifier    = hash

[client_ext]
authorityInfoAccess     = @issuer_info
authorityKeyIdentifier  = keyid:always
basicConstraints        = critical,CA:false
crlDistributionPoints   = @crl_info
extendedKeyUsage        = clientAuth
keyUsage                = critical,digitalSignature
subjectKeyIdentifier    = hash
EOF
fi

mkdir -p certs db private
chmod 700 private
touch db/index
[ -f db/serial ] || openssl rand -hex 16 > db/serial
[ -f db/crlnumber ] || echo 1001 > db/crlnumber

if [ ! -f my-root-ca.crt ]; then
  openssl req -new -config my-root-ca.conf -out my-root-ca.csr -keyout private/my-root-ca.key -noenc
  openssl ca -selfsign -config my-root-ca.conf -in my-root-ca.csr -notext -out my-root-ca.crt -extensions ca_ext -batch
  rm my-root-ca.csr
fi
