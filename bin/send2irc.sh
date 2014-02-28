#!/usr/bin/env bash

SERVER=$1
NICK=$2
CHANNEL=$3
MESSAGE=$4
read ADDRESS PORT <<< $(IFS=":"; echo $SERVER)
NICK="$NICK$(tr -dc 0-9 < /dev/urandom | head -c 4 | xargs)"

echo -e "USER $NICK i BLAH $NICK\nNICK $NICK\nJOIN $CHANNEL\nPRIVMSG $CHANNEL :$MESSAGE\nQUIT\n" | nc $ADDRESS $PORT
