#!/bin/bash

set -e

export $(grep -v '^#' .env | xargs -0) > /dev/null

FORCE=false

if [ -z "$DATA_DIR" ]; then
    echo "DATA_DIR is not set"
    exit 1
fi


if [ "$1" == "-f" ]; then
    FORCE=true
fi

if [ "$FORCE" == "false" ]; then
    echo "This will delete all generated certificates and keys"
    find $DATA_DIR/root
    find $DATA_DIR/servers
    find $DATA_DIR/clients

    echo
    echo "please type 'please' to confirm"
    read CONFIRM
    if [ "$CONFIRM" != "please" ]; then
        echo "abort"
        exit 1
    fi
fi

echo "deleting all generated certificates and keys"
find $DATA_DIR/root
find $DATA_DIR/servers
find $DATA_DIR/clients

rm -rf $DATA_DIR/root
rm -rf $DATA_DIR/servers
rm -rf $DATA_DIR/clients