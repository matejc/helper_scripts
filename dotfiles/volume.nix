{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/volume";
  source = pkgs.writeScript "volume.sh" ''
    #!${pkgs.stdenv.shell}
    # Usage: volume <card> {increase|decrease|toggle}
    export PATH="${pkgs.pulseaudioLight}/bin:${pkgs.busybox}/bin"
    pulsefolder="/tmp/pulse"
    mkdir -p $pulsefolder

    #### Create $pulsefolder/mute if not exists
    ls $pulsefolder/mute &> /dev/null
    if [[ $? != 0 ]]
    then
        echo "false" > $pulsefolder/mute
    fi

    ####Create $pulsefolder/volume if not exists
    ls $pulsefolder/volume &> /dev/null
    if [[ $? != 0 ]]
    then
        echo "0" > $pulsefolder/volume
    fi

    CURVOL=`cat $pulsefolder/volume`     #Reads in the current volume
    MUTE=`cat $pulsefolder/mute`          #Reads mute state

    if [[ $2 == "increase" ]]
    then
        CURVOL=$(($CURVOL + 3277)) #3277 is 5% of the total volume, you can change this to suit your needs.
        if [[ $CURVOL -ge 65536 ]]
        then
            CURVOL=65536
        fi
    elif [[ $2 == "decrease" ]]
    then
        CURVOL=$(($CURVOL - 3277))
        if [[ $CURVOL -le 0 ]]
        then
            CURVOL=0
        fi
    elif [[ $2 == "toggle" ]]
    then
        if [[ $MUTE == "false" ]]
        then
            pactl set-sink-mute $1 1
            echo "true" > $pulsefolder/mute
            exit
        else
            pactl set-sink-mute $1 0
            echo "false" > $pulsefolder/mute
            exit
        fi
    fi

    pactl set-sink-volume $1 $CURVOL
    echo $CURVOL > $pulsefolder/volume # Write the new volume to disk to be read the next time the script is run.
  '';
}
