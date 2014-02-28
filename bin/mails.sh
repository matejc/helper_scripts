#!/bin/bash

MAILS_FILE="/tmp/testUnread"

if [ -f $MAILS_FILE ];
then
    MAILS_COUNT=$(cat $MAILS_FILE)
    if [ "$MAILS_COUNT" -ne "0"  ];
    then
        echo $MAILS_COUNT
        exit 0
    fi
fi
echo ""
