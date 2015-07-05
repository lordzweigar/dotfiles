#Xrandr script:
~/.screenlayout/display.sh

#pcmanfm daemon - useful for automatic mounting of drives
pcmanfm -d &

#load Xresources
xrdb -load  /home/$USER/.Xresources &

#background
~/.fehbg &

#compositing
compton &

#mpd
mpd ~/.config/mpd/mpd.conf &

#make the default x cursor not an x :)
xsetroot -cursor_name left_ptr &
setxkbmap -rules evdev -model evdev -layout us -variant altgr-intl

#dunst
. ~/.bspwm_theme
dunst -geometry 200x200-10-10 \
    -fn "$DUNST_FONT" \
    -lb "$defaultBG" -lf "$defaultFG" \
    -nb "$defaultBG" -nf "$defaultFG" \
    -cb "$defaultBG" -cf "#ffff00" &

#check if existing socket exists and killl for bspwm(doesn't play nice with logging out and in)
rm /tmp/$(ls /tmp | grep bspwm)

#set shell that sxhkd uses to execute commands:
export SXHKD_SHELL=sh

#start bspwm and sxhkd
xfce4-power-manager &
xrandr --output VGA-1 --off --output HDMI-1 --mode 1680x1050 --pos 0x390 --rotate normal --output DVI-D-1 --mode 2560x1440 --pos 1680x0 --rotate normal --output DVI-D-2 --mode 1680x1050 --pos 4240x390 --rotate normal &
emacs --daemon &
sxhkd -f 1000 -c /home/$USER/.config/sxhkd/sxhkdrc &
exec bspwm -c /home/$USER/.config/bspwm/bspwmrc > .xinit.log
