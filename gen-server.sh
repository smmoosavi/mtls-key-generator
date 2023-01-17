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
    echo "Usage: $0 <CN> [subjectAltName]"
    exit 1
fi

ROOT="$DATA_DIR/root"
ROOT_CRT="$ROOT/root-ca.crt"
ROOT_KEY="$ROOT/root-ca.key"

SERVER_DIR="$DATA_DIR/servers/$CN"
SERVER_KEY="$SERVER_DIR/server.key"
SERVER_CSR="$SERVER_DIR/server.csr"
SERVER_CRT="$SERVER_DIR/server.crt"
SERVER_CNF="$SERVER_DIR/server.cnf"


if [ -d "$SERVER_DIR" ]; then
    echo "Directory '$SERVER_DIR' already exists"
    exit 1
fi

mkdir -p $SERVER_DIR
cp config/server.cnf $SERVER_DIR/

# add subjectAltName: e.g.
# subjectAltName = DNS:docker.local, DNS:localhost, IP:127.0.0.1 to server.cnf

if [ ! -z "$ALTNAMES" ]; then
    echo "subjectAltName = $ALTNAMES" >> $SERVER_CNF
fi

set -x

openssl genrsa -out "$SERVER_KEY" 4096
openssl req -new -key "$SERVER_KEY" -out "$SERVER_CSR" -sha256 -subj "/CN=$CN"
openssl x509 -req -days 750 -in "$SERVER_CSR" -sha256 -CA "$ROOT_CRT" -CAkey "$ROOT_KEY" -CAcreateserial -out "$SERVER_CRT" -extfile "$SERVER_CNF" -extensions server