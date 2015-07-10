#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# define a standard background and foreground variable.
getTermColor() {
    echo -n "#$( cat ~/.config/termite/config | grep  "$1" | head -n 1 | grep -oE "#[a-zA-Z0-9]{6}" | cut -c 2- )";
}

export defaultBG="$(getTermColor background)"
export defaultFG="$(getTermColor foreground)"
export activeFG="$(getTermColor color15)"


# Panel scripts.
PATH=$PATH:~/bin:~/.config/bar

# add the dir for gem execs to path:
PATH=$PATH:/home/$USER/.gem/ruby/2.2.0/bin


# Paths
PATH=$PATH:/home/$USER/scripts
# auto-complete for pacman when using sudo:
complete -cf sudo

# functions

function swap() {
    # Swap 2 filenames around, if they exist (from Uzi's bashrc).
    local TMPFILE=tmp.$$

    [ $# -ne 2 ] && echo "swap: 2 arguments needed" && return 1
    [ ! -e $1 ] && echo "swap: $1 does not exist" && return 1
    [ ! -e $2 ] && echo "swap: $2 does not exist" && return 1

    mv "$1" $TMPFILE
    mv "$2" "$1"
    mv $TMPFILE "$2"
}

function extract()      # Handy Extract Program
{
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xvjf $1     ;;
            *.tar.gz)    tar xvzf $1     ;;
            *.bz2)       bunzip2 $1      ;;
            *.rar)       unrar x $1      ;;
            *.gz)        gunzip $1       ;;
            *.tar)       tar xvf $1      ;;
            *.tbz2)      tar xvjf $1     ;;
            *.tgz)       tar xvzf $1     ;;
            *.zip)       unzip $1        ;;
            *.Z)         uncompress $1   ;;
            *.7z)        7z x $1         ;;
            *)           echo "'$1' cannot be extracted via >extract<" ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

# Handy blocking script
# I should have used getopts but i'm too lazy

function block()
    if [ -n $1 ] ; then

          echo 'blocked' $1 && sudo echo  "0.0.0.0  $1" >> /etc/hosts && sudo systemctl restart nscd
     else
        echo  'Successfully blocked nothing'
    fi

function unblock()
    if [ -n $1 ] ; then
        echo 'unblocked' $1 && sudo sed -i '/$1/d' /etc/hosts  && sudo systemctl restart nscd
     else
        echo  'Successfully unblocked nothing'
    fi
alias unblockall="sudo mv /etc/hosts /etc/hosts-unblocked && sudo systemctl restart nscd"
alias   blockall="sudo mv /etc/hosts-unblocked /etc/hosts && sudo systemctl restart nscd"





prompt () {
    _ERR=$?
    _UID=$(id -u)
    _JOB=$(jobs | wc -l)

    [ $_UID -eq 0 ] && echo -n '━' || echo -n -e '─'
    [ $_JOB -ne 0 ] && echo -n '!' || echo -n -e '─'
    [ $_ERR -ne 0 ] && echo -n '!' || echo -n -e '─'
}

PS1='$(prompt) '

# aliases
alias tmux='tmux -2' #Make tmux assume 256 colors.
alias cavampd='cava -i fifo -p /tmp/mpd.fifo -b 20'
alias info='info --vi-keys'
#alias vim='nvim'
alias sysinfo='archey3 && dfc -p /dev && colors'
alias ls='ls --color=auto'
alias paste="curl -F 'sprunge=<-' http://sprunge.us"
alias grep="grep --color=auto"
alias pacman="pacman --color=always"
#alias make="clear && make"
alias shot="scrot ~/Screenshots/`date +%y-%m-%d-%H:%M:%S`.png"
alias getip="curl -s checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//'"

# my aliases
alias best="youtube-dl -i -f 'bestvideo+bestaudio'"
alias besta="youtube-dl -i -f 'bestaudio'"
alias bestv="youtube-dl -i -f 'bestvideo'"
alias nsync="rsync -PRra -e ssh"

# programs
export EDITOR=vim
export BROWSER=firefox
# autostart if running on the first tty:
if [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]]; then exec startx; fi
alias fzf=fzf --color=16,fg:7,info:11,fg+:1,hl+:4,hl:1 --inline-info
