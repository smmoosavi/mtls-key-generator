#!/bin/bash

set -e

export $(grep -v '^#' .env | xargs -0) > /dev/null

if [ -z "$DATA_DIR" ]; then
    echo "DATA_DIR is not set"
    exit 1
fi


CN=$1

if [ -z "$CN" ]; then
    echo "Usage: $0 <CN>"
    exit 1
fi

ROOT="$DATA_DIR/root"
ROOT_KEY="$ROOT/root-ca.key"
ROOT_CSR="$ROOT/root-ca.csr"
ROOT_CRT="$ROOT/root-ca.crt"
ROOT_CNF="$ROOT/root-ca.cnf"


if [ -d "$ROOT" ]; then
    echo "Directory '$ROOT' already exists"
    exit 1
fi

mkdir -p $ROOT
cp config/root-ca.cnf $ROOT/

set -x

# root
openssl genrsa -out "$ROOT_KEY" 4096
openssl req -new -key "$ROOT_KEY" -out "$ROOT_CSR" -sha256 -subj "/CN=$CN"
openssl x509 -req -days 3650 -in "$ROOT_CSR" -signkey "$ROOT_KEY" -sha256 -out "$ROOT_CRT" -extfile "$ROOT_CNF" -extensions root_ca
