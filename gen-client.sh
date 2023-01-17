#!/bin/bash

set -e

export $(grep -v '^#' .env | xargs -0) > /dev/null

if [ -z "$DATA_DIR" ]; then
    echo "DATA_DIR is not set"
    exit 1
fi

CN=$1
ALTNAMES=$2

if [ -z "$CN" ]; then
    echo "Usage: $0 <CN>"
    exit 1
fi

ROOT="$DATA_DIR/root"
ROOT_CRT="$ROOT/root-ca.crt"
ROOT_KEY="$ROOT/root-ca.key"

CLIENT_DIR="$DATA_DIR/clients/$CN"
CLIENT_KEY="$CLIENT_DIR/client.key"
CLIENT_CSR="$CLIENT_DIR/client.csr"
CLIENT_CRT="$CLIENT_DIR/client.crt"
CLIENT_CNF="$CLIENT_DIR/client.cnf"
CLIENT_PEM="$CLIENT_DIR/client.pem"
CLIENT_PFX="$CLIENT_DIR/client.pfx"


if [ -d "$CLIENT_DIR" ]; then
    echo "Directory '$CLIENT_DIR' already exists"
    exit 1
fi

mkdir -p $CLIENT_DIR
cp config/client.cnf $CLIENT_DIR/

set -x

openssl genrsa -out "$CLIENT_KEY" 4096
openssl req -new -key "$CLIENT_KEY" -out "$CLIENT_CSR" -sha256 -subj "/CN=$CN"
openssl x509 -req -days 750 -in "$CLIENT_CSR" -sha256 -CA "$ROOT_CRT" -CAkey "$ROOT_KEY" -CAcreateserial -out "$CLIENT_CRT" -extfile "$CLIENT_CNF" -extensions client
cat "$CLIENT_KEY" "$CLIENT_CRT" "$ROOT_CRT" > "$CLIENT_PEM"
openssl pkcs12 -export -out "$CLIENT_PFX" -inkey "$CLIENT_KEY" -in "$CLIENT_PEM" -certfile "$ROOT_CRT"