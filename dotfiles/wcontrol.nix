{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/maximize";
  source = pkgs.writeScript "maximize.sh" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.wmctrl}/bin/wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz
  '';
}{
  target = "${variables.homeDir}/bin/minimize";
  source = pkgs.writeScript "minimize.sh" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.wmctrl}/bin/wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
  '';
}{
  target = "${variables.homeDir}/bin/maximize-to-side";
  source = pkgs.writeScript "maximize-to-side.py" ''
    #!${pkgs.stdenv.shell}
    export PATH="${pkgs.wmctrl}/bin:${pkgs.xorg.xdpyinfo}/bin:${pkgs.disper}/bin:$PATH"

    ## If no side has been given, maximize the current window and exit
    if [ ! $1 ]
    then
        wmctrl -r :ACTIVE: -b toggle,maximized_vert,maximized_horz
        exit
    fi

    # If a side has been given, continue
    side=$1;
    ## How many screens are there?
    screens=`disper -l | grep -c display`
    ## Get screen dimensions
    WIDTH=`xdpyinfo | grep 'dimensions:' | cut -f 2 -d ':' | cut -f 1 -d 'x'`;
    HALF=$(($WIDTH/2));

    ## If we are running on one screen, snap to edge of screen
    if [ $screens == '1' ]
    then
        ## Snap to the left hand side
        if [ $side == 'l' ]
        then
            ## wmctrl format: gravity,posx,posy,width,height
            wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
            wmctrl -r :ACTIVE: -b add,maximized_vert && wmctrl -r :ACTIVE: -e 0,0,0,$HALF,-1
        ## Snap to the right hand side
        else
            wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
            wmctrl -r :ACTIVE: -b add,maximized_vert && wmctrl -r :ACTIVE: -e 0,$HALF,0,$HALF,-1
        fi
    ## If we are running on two screens, snap to edge of right hand screen
    ## I use 1600 because I know it is the size of my laptop display
    ## and that it is not the same as that of my 2nd monitor.
    else
        LAPTOP=1600; ## Change this as approrpiate for your setup.
        let "WIDTH-=LAPTOP";
        SCREEN=$LAPTOP;
        HALF=$(($WIDTH/2));
        if [ $side == 'l' ]
        then
            wmctrl -r :ACTIVE: -b add,maximized_vert && wmctrl -r :ACTIVE: -e 0,$LAPTOP,0,$HALF,-1
        else
        let "SCREEN += HALF+2";
        wmctrl -r :ACTIVE: -b add,maximized_vert && wmctrl -r :ACTIVE: -e 0,$SCREEN,0,$HALF,-1;
        fi
    fi
  '';
}]


