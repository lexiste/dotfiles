#=============================================================================#
# Personal ~/.bashrc file, find something I like, then make sure everyone has 
# it.
#
# Last Updated: Mon Jun  5 20:48:01 EDT 2017
# 
# Ideas from:
#  http://tldp.org/LDP/abs/html/sample-bashrc.html
#
# The choice of colors was done for a shell with a dark background (white on 
# black), and this is usually also suited for pure text-mode consoles (no X 
# server available). If you use a white background, you'll have to do some 
# other choices for readability.
#
#=============================================================================#

# if we are not interactive, then do nothing 
[ -z "$PS1" ] && return

# Global definations if it exists
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

#=============================================================================#
# Automatic setting of $DISPLAY (if not set already).
# This works for me - your mileage may vary. . . .
# The problem is that different types of terminals give different answers to 
# 'who am i' (rxvt in particular can be # troublesome) - however this code
# seems to work in a majority # of cases.
#=============================================================================#

function get_xserver () {
  case $TERM in
    xterm )
      XSERVER=$(who am i | awk '{print $NF}' | tr -d ')''(' )
      XSERVER=${XSERVER%%:*}
    ;;
    aterm | rxvt)
    # Find some code that works here. ...
    ;;
  esac
}

if [ -z ${DISPLAY:=""} ]; then
  get_xserver
  if [[ -z ${XSERVER}  || ${XSERVER} == $(hostname) || ${XSERVER} == "unix" ]]; then
    DISPLAY=":0.0"          # Display on local host.
  else
    DISPLAY=${XSERVER}:0.0     # Display on remote host.
  fi
fi

export DISPLAY

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

echo -e "${BCYAN}This is BASH ${BRED}${BASH_VERSION%.*} - ${BCyan}DISPLAY${NC} on ${BRed}$DISPLAY${NC}"
echo -e "It is now: ${ALERT}$(date +%c)${NC}\n"
if [ -x /usr/games/fortune ]; then
  echo -e "$(/usr/games/fortune -s)\n"
fi

function _exit() {
  echo -e "${BRed}See ya'll later, enjoy!${NC}"
}
trap _exit EXIT


#=============================================================================#
# Shell Prompts
# ----------------------------------
# Time:
#   Green   = machine load low
#   Orange  = machine load moderate
#   Red     = machine load high
#   ALERT   = machine load critical
# User:
#   Green   = normal user logong
#   Cyan    = user not matched to logon name
#   Red     = root user logon
# Host:
#   Cyan    = local session (console)
#   Green   = secure remote session (SSH)
#   Red     = insecure remote session (Telnet, should not be in use)
# Directory:
#   Green   = >= 15% free disk space
#   Orange  = < 15% free disk space
#   ALERT   = < 5% free disk space
#   Red     = current user does not have write access
#=============================================================================#


# Test the connection type:
if [ -n "${SSH_CONNECTION}" ]; then
  CNX=${Green}
elif [[ "$DISPLAY%%:0*}" != "" ]]; then
  CNX=${Cyan}
else
  CNX=${BRed}
fi

# Test the user type:
if [[ ${UID} -eq 0 ]]; then
  SU=${BRED}
elif [[ "${USER}" == "${LOGNAME}" ]]; then
   if [[ ${SUDO_USER} ]]; then
      SU=${BCyan}
   else
      SU=${Green}
   fi
else
  SU=${Green}
fi

# Test processor load:
NCPU=$(grep -c 'processor' /proc/cpuinfo) # find number of CPU's 
SLOAD=$(( 100*${NCPU} ))  # light load 
MLOAD=$(( 200*${NCPU} ))  # moderate load
XLOAD=$(( 400*${NCPU} ))  # high load

function load() {
  local SYSLOAD=$(cut -d " " -f1 /proc/loadavg | tr -d '.')
  echo $((10#$SYSLOAD))   # convert to decimal
}

# Return color based on system load
function load_color() {
  local SYSLOAD=$(load)
  if [ ${SYSLOAD} -gt ${XLOAD} ]; then
    echo -en ${ALERT}
  elif [ ${SYSLOAD} -gt ${MLOAD} ]; then
    echo -en ${Red}
  elif [ ${SYSLOAD} -gt ${SLOAD} ]; then
    echo -en ${BRed}
  else
    echo -en ${Green}
  fi
}

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

extract () {
   if [ -f $1 ] ; then
      case $1 in
         *.tar.bz2)  tar xjf $1     ;;
         *.tar.gz)   tar xzf $1     ;;
         *.bz2)      bunzip2 $1     ;;
         *.rar)      rar x $1    ;;
         *.gz)    gunzip $1      ;;
         *.tar)      tar xf $1      ;;
         *.tbz2)     tar xjf $1     ;;
         *.tgz)      tar xzf $1     ;;
         *.zip)      unzip $1    ;;
         *.Z)     uncompress $1  ;;
         *)       echo "'$1' cannot be extracted via extract()" ;;
       esac
   else
      echo "'$1' is not a valid file"
   fi
                                                                                                                              }
PROMPT_HISTORY="history -a"
case ${TERM} in
  *term | rxvt | linux | xterm-256color)
  # for some reason, the load_color() does not seem to be evaluated
  # $SU does not appear to be evaluated properly
    PS1="${load_color}\A${NC} ${SU}\u${NC}@${CNX}\h${NC} ${disk_color}\w${NC}\n--\\$ \[$(tput sgr0)\] "
    ;;
  *)
    #PS1="${load_color}\A${NC} ${SU}\u${NC}@${CNX}\h${NC} ${disk_color}\w${NC}\n--> "
    PS1="\A \u@\h \w "
  ;;
esac

export PATH=${PATH}:/usr/local/scripts:~/scripts
export TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
export HISTIGNORE="&:ls:bg:fg:ll:h"
export HISTTIMEFORMAT="$(echo -e ${BCyan})[%d/%m %H:%M:%S]$(echo -e ${NC}) "
export HISTCONTROL=ignoredups
export HOSTFILE=$HOME/.hosts    # Put a list of remote hosts in ~/.hostsf

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
alias df='df -kTh'

# add color and various flags
alias ls='ls -halG --color=auto'
alias l='ls -hl --color=auto'
alias ll='ls -lv --group-directories-first'
alias la='ll -A'           #  Show hidden files.
alias lk='ls -lSr'         #  Sort by size, biggest last.
alias ld='ls -ltr'         #  Sort by date, most recent last.
alias lc='ls -ltcr'        #  Sort by/show change time,most recent last.

# aliases for the lazy person I am
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias mc='mc -x'
alias ports='sudo netstat -tulanp | less'
alias reboot='sudo /sbin/reboot'
alias shutdown='sudo /sbin/poweroff'
alias drop='~/.dropbox-dist/dropboxd &'
alias ipt='sudo iptables -L --line-numbers'
alias ip='ip -human -details -a -color a'
alias ct='ssh -i ~/Dropbox/Private/Identity todd@176.58.109.109'
alias nat='curl http://icanhazip.com'
alias weather='curl http://wttr.in'
alias shred='shred -v -n5'
alias loads='grep -c 'processor' /proc/cpuinfo; uptime;'
alias tb='~/.local/share/torbrowser/tbb/x86_64/tor-browser_en-US/start-tor-browser.desktop'
