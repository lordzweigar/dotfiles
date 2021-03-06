#!/bin/sh
# info.sh
# Output information with formatted background colors in lemonbar format
# This script can take arguments for what bar information to display(meant to be the names of the functions)

# clickable area aliases
AC='%{A:'           # start click area
AB=':}'             # end click area cmd
AE='%{A}'           # end click area

icon() {
    echo -n -e "%{F$pIcon}\u$1 %{F$pFG}"
}

#weather() {
#    icon f0c2
#    weatherURL='http:http://www.accuweather.com/en/au/cairns/13968/weather-forecast/13968'
#    wget -q -O- "$weatherURL" | awk -F\' '/acm_RecentLocationsCarousel\.push/{print $12"°C" }'| head -1
#}

clock() {
    icon f073
    date '+%b%e,%l:%M:%S'
}

mail() {
    # todo: this
    icon f0e0
    echo '0'
}

battery() {
    BATC=/sys/class/power_supply/BAT0/capacity
    BATS=/sys/class/power_supply/BAT0/status
    icon f0e7
    if [ -f $BATC ]; then
        [ "`cat $BATS`" = "Charging" ] && echo -n '+' || echo -n '-'
        cat $BATC
    else
        #no battery information found.
        echo '+100'
    fi
}

volume() {
    display="$(icon f028) $(amixer get Master | sed -n 's/^.*\[\([0-9]\+%\).*$/\1/p')"
    command='termite -e "alsamixer"'
    echo ${AC}$command${AB}$display${AE}
}

network() {
    read lo int1 int2 <<< `ip link | sed -n 's/^[0-9]: \(.*\):.*$/\1/p'`
    if iwconfig $int1 >/dev/null 2>&1; then
        wifi=$int1
        eth0=$int2
    else
        wifi=$int2
        eth0=$int1
    fi
    ip link show $eth0 | grep 'state UP' >/dev/null && int=$eth0 ||int=$wifi
    icon f0ac
      ping -W 1 -c 1 10.0.0.138 >/tmp/maymay.txt 2>&1 &&
#          echo -e '\uf00c' || echo -e '\uf00d'
      echo $(grep -o -P '(time=).*(ms)' /tmp/maymay.txt)
    }

mpd() {
    cur_song=$(mpc current | cut -c1-30)

    icon f025
    if [ -z "$cur_song" ]; then
        echo "Stopped"
    else
        paused=$(mpc | grep paused)
        [ -z "$paused" ] && toggle="${AC}mpc pause${AB}$(icon f04c)${AE}" ||
            toggle="${AC}mpc play${AB}$(icon f04b)${AE}"
        prev="${AC}mpc prev${AB}$(icon f049)${AE}"
        next="${AC}mpc next${AB}$(icon f050)${AE}"
        echo "$cur_song $prev$toggle$next"
    fi
}

yaourtUpdates() {
    updates=$(eval yaourt -Qu | wc --lines)
    command='termite -e "yaourt -Syua"'
    echo ${AC}$command${AB}$(icon f062)$updates${AE}
}

themeSwitch() {
    # ghetto
    # todo: replace with dmenu or dzen dropdown to click themes from dir.
    cur_theme=$(cat ~/.bspwm_theme | grep THEME_NAME | cut -c12-)
    case $cur_theme in
        pyonium) next_theme=zenburn;;
        zenburn) next_theme=jellybean;;
        jellybean) next_theme=pyonium;;
    esac
    command="ltheme $next_theme"
    icon f01e
    echo ${AC}$command${AB}$cur_theme${AE}
}

#determine what to display based on arguments, unless there are none, then display all.
while :; do
    buf="S%{F$pFG}"

    [ -z "$*" ] && items="mail yaourtUpdates mpd battery network volume weather clock themeSwitch" \
                || items="$@"

    for item in $items; do
        buf="${buf}%{B$pBGInactiveTab}$(printf %${pPadding}s)$($item)$(printf %${pPadding}s)${delim}";
    done

    echo "$buf%{B$pBG}"
    sleep 0.8 # The HUD will be updated every second
done


if [ `ps -e | grep -c $(info.sh $0)` -gt 2 ]; then exit 0; fi
