#!/usr/bin/env bash

# OUTPUT="$(xrandr -q)"
export PATH="/run/current-system/sw/bin"

IFS=$'\n'; LINES=($(xrandr -q))

COUNT=0
DISCONNECTSTR=
unset NEXT_PRIMARY_MODE
unset NEXT_EXT_MODE

for line in "${LINES[@]}"
do
    if [ -n "$NEXT_PRIMARY_MODE" ]
    then
        PRIMARY_W=$(echo "$line" | awk '{printf $1}' | awk -Fx '{printf $1}')
        PRIMARY_H=$(echo "$line" | awk '{printf $1}' | awk -Fx '{printf $2}')
        unset NEXT_PRIMARY_MODE
    elif [ -n "$NEXT_EXT_MODE" ]
    then
        EXT_W=$(echo "$line" | awk '{printf $1}' | awk -Fx '{printf $1}')
        EXT_H=$(echo "$line" | awk '{printf $1}' | awk -Fx '{printf $2}')
        unset NEXT_EXT_MODE
    elif [[ "$line" = *primary* || ($COUNT = 0 && "$line" = *\ connected*) ]]
    then
        PRIMARY=$(echo "$line" | awk '{printf $1}')
        COUNT=$((COUNT + 1))
        NEXT_PRIMARY_MODE=true
    elif [[ "$line" = *\ connected* ]]
    then
        EXT=$(echo "$line" | awk '{printf $1}')
        COUNT=$((COUNT + 1))
        NEXT_EXT_MODE=true
    elif [[ "$line" = *disconnected* ]]
    then
        DISCONNECTSTR="$DISCONNECTSTR --output $(echo "$line" | awk '{printf $1}') --off"
    fi
done

MON0="{ \"monitor\": \"$PRIMARY\", \"width\": $PRIMARY_W, \"height\": $PRIMARY_H }"
MON1="{ \"monitor\": \"$EXT\", \"width\": $EXT_W, \"height\": $EXT_H }"

if [ -n "$EXT" ]; then
    echo "{ \"count\": $COUNT, \"mon0\": $MON0, \"mon1\": $MON1 }"
    bash -c "xrandr --output $PRIMARY --primary --auto --output $EXT --auto --right-of $PRIMARY $DISCONNECTSTR"
else
    echo "{ \"count\": $COUNT, \"mon0\": $MON0 }"
    bash -c "xrandr --output $PRIMARY --primary --auto $DISCONNECTSTR"
fi
