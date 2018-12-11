#=============================================================================#
# Personal ~/.bashrc file, find something I like, then make sure everyone has 
# it.
#
# Last Updated: 01.Nov.2018 10.00
# 
# Ideas from:
#  http://tldp.org/LDP/abs/html/sample-bashrc.html
#=============================================================================#

# if we are not interactive, then do nothing 
[ -z "$PS1" ] && return

# Global definations if it exists
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# Some house-keeping
shopt -s cdspell
shopt -s cmdhist
set -o vi

# Set some color definations (from Color Bash HowTo) 
#
# Normal Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

NC="\e[m"               # Color Reset


ALERT=${BWhite}${On_Red} # Bold White on red background
ALL_GOOD=${BWhite}${On_Green} # Bold White on red background

#echo -e "${BCYAN}This is BASH ${BRED}${BASH_VERSION%.*}${NC} - ${BCyan}DISPLAY${NC}"
echo -e "It is now: ${ALL_GOOD}$(date +%c)${NC}\n"

function _exit() {
  echo -e "${BRed}See ya'll later, enjoy!${NC}"
}
trap _exit EXIT

# Test the user type:
if [ ${USER} == "root" ]; then
  ME=${BRed}
elif [[ "${USER}" -eq "${LOGNAME}" ]]; then
   if [ ${SUDO_USER} ]; then
      ME=${BCyan}
   else
      ME=${Green}
   fi
else
  ME=${Green}
fi

# Test the connection type:
if [[ -n "${SSH_CONNECTION}" ]]; then
  CNX=${Green}
elif [[ -t 0 ]]; then
  CNX=${Cyan}
else
  CNX=${BRed}
fi

# Returns a color according to free disk space in $PWD.
function disk_color() {
  if [ ! -w "${PWD}" ]; then # no write privileges in the current directory
    echo -en ${Red}
  elif [ -s "${PWD}" ] ; then
    local used=$(command df -P "$PWD" | awk 'END {print $5} {sub(/%/,"")}')
    if [ ${used} -gt 95 ]; then
      echo -en ${ALERT}           # Disk almost full (>95%).
    elif [ ${used} -gt 85 ]; then
      echo -en ${BRed}            # Free disk space almost gone.
    else
      echo -en ${Green}           # Free disk space is ok.
    fi
  else
    echo -en ${Cyan}              # Current directory is size '0' (like /proc, /sys etc
  fi
}

thirdline () {
   # function that will print every third line green to make reading easier
   awk '{if (NR%3==0){print "\033[32m" $0 "\033[0m"} else{print}}';
}

extract () {
   if [ -f $1 ] ; then
      case $1 in
         *.tar.bz2)  tar xjf $1     ;;
         *.tar.gz)   tar xzf $1     ;;
         *.bz2)      bunzip2 $1     ;;
         *.rar)      rar x $1       ;;
         *.gz)       gunzip $1      ;;
         *.tar)      tar xf $1      ;;
         *.tbz2)     tar xjf $1     ;;
         *.tgz)      tar xzf $1     ;;
         *.zip)      unzip $1       ;;
         *.Z)     uncompress $1     ;;
         *)       echo "'$1' cannot be extracted via extract()" ;;
       esac
   else
      echo "'$1' is not a valid file"
   fi
}

PROMPT_HISTORY="history -a"
case ${TERM} in
  *term | rxvt | linux | xterm-256color)
    #PS1="[\d \@] [\#] \u@${CNX}\h${NC} ${disk_color}\w${NC}\n--\\$ "
    #PS1="[\#] \D{%d%b %H:%M} ${ME}\u${NC}@${CNX}\h${NC}:${disk_color}\w${NC}\n\$ "
    PS1="[\#] \D{%d-%b %H:%M} ${ME}\u${NC} on ${CNX}\h${NC} in ${disk_color}\w${NC}\n"'\$ '
    #PS1="---[\#] ${ME}\u${NC} on ${CNX}\h${NC}\n-(\D{%d%b %H:%M})---> "
    #cat /etc/motd
    ;;
  *)
    #PS1="\A \u at \h \w \$"
    PS1="\D{%d-%b %H:%M} ${ME}\u${NC} in ${disk_color}\w{$NC}\$ "
  ;;
esac

export PATH=${PATH}:/usr/local/scripts:~/scripts
export TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
export HISTIGNORE="&:ls:bg:fg:ll:h"
export HISTTIMEFORMAT="$(echo -e ${BCyan})[%d/%m %H:%M:%S]$(echo -e ${NC}) "
export HISTCONTROL=ignoredups
export HOSTFILE=$HOME/.hosts    # Put a list of remote hosts in ~/.hosts

#============================
# Aliases for commands I typically fat finger, or where I'm just lazy
#============================
# fat finger
alias xs='cd'
alias vf='cd'
alias moer='more'
alias moew='more'
alias kk='ll'
alias cls='clear'
alias celar='clear'
alias ckear='clear'

# protect clobbering files
alias rm='rm -iv'
alias cp='cp -iv'
alias mv='mv -iv'
alias mkdir='mkdir -p'
alias more='less'
alias nc='nc -v'

# updates and installers
alias ins='sudo apt-get install'
alias rem='sudo apt-get purge'
alias upd='sudo apt-get update'
alias upg='sudo apt-get upgrade'
alias upup='sudo apt-get update -y && sudo apt-get upgrade -y'

# lazy old me
alias which='type -a'
alias ..='cd ..'
alias du='du -kh'       # more readable output
alias df='df -h'

# add color and various flags
alias ls='ls -hlG --time-style=+"%Y-%m-%d %H:%M:%S" --color=auto'
alias lc='ls -ltcr'        #  Sort by/show change time,most recent last.
alias lf=lc

# aliases for the lazy person I am
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias mc='mc -x'
alias ports='sudo netstat -tulanp | less'
alias reboot='sudo /sbin/reboot'
alias shutdown='sudo /sbin/poweroff'
alias ipt='sudo iptables -L --line-numbers --numeric --verbose'
alias ip='ip -human -details -a -color a'
alias nat='echo -n "ext IP: ";curl -s https://api.ipify.org;echo'

alias weather='curl http://wttr.in'
alias shred='shred -n5 -u'

# launch tmux with a default screen setup
#alias tmux.main='tmux new-session -s main \; send-keys 'htop' C-m \; split-window -v -p 75 \; split-window -h -p 50 \;'
alias tmux.main='tmux new-session -s main \; split-window -h -p 50 \;'

