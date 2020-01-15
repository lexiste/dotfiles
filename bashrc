#=============================================================================#
# Personal ~/.bashrc file, find something I like, then make sure everyone has
# it.
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
## https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
shopt -s cdspell
shopt -s cmdhist
shopt -s dirspell
shopt -s histappend
shopt -s histverify
chattr +a ~/.bash_history
set -o vi

##########################################################################
# XXX: Coloured variables
#  https://misc.flogisoft.com/bash/tip_colors_and_formatting
#  fg, bg and format can be chained together like
#  ${bold}${uline}${red}My Name is${normal}${yellow}${blink}Fred${normal}
##########################################################################
## foreground colors
red=`echo -e "\033[31m"`
green=`echo -e "\033[32m"`
yellow=`echo -e "\033[33m"`
blue=`echo -e "\033[34m"`
purple=`echo -e "\033[35m"`
cyan=`echo -e "\033[36m"`
lt_red=`echo -e "\033[91m"`
lt_green=`echo -e "\033[92m"`
white=`echo -e "\033[97m"`

## background colors .. don't need many
bg_normal=`echo -e "\033[49m"`
bg_white=`echo -e "\033[40m"`
bg_red=`echo -e "\033[41m"`
bg_green=`echo -e "\033[42m"`

## text setting
normal=`echo -e "\033[0m"`
bold=`echo -e "\033[1m"`
uline=`echo -e "\033[4m"`
blink=`echo -e "\033[5m"`
hide=`echo -e "\033[8m"`

ALERT=${bold}${bg_white}${red} # Bold White on red background
#ALL_GOOD=${bold}${bg_green}${white} # Bold White on red background
ALL_GOOD=${lt_green}

echo -e "It is now: ${ALL_GOOD}$(date +%c)${normal}\n"

##### FUNCTIONS #####
thirdline () {
   # function that will print every third line green to make reading easier
   awk '{if (NR%3==0){print "\033[32m" $0 "\033[0m"} else{print}}';
}

function _exit() {
  echo -e "${bg_white}${red}See ya'll later, enjoy!${normal}"
}
trap _exit EXIT

# Returns a color according to free disk space in $PWD.
function disk_color() {
  if [ ! -w "${PWD}" ]; then # no write privileges in the current directory
    echo -en ${Red}
  elif [ -s "${PWD}" ] ; then
    local used=$(command df -P "$PWD" | awk 'END {print $5} {sub(/%/,"")}')
    if [ ${used} -gt 95 ]; then
      echo -en ${ALERT}           # Disk almost full (>95%).
    elif [ ${used} -gt 85 ]; then
      echo -en ${lt_red}            # Free disk space almost gone.
    else
      echo -en ${green}           # Free disk space is ok.
    fi
  else
    echo -en ${cyan}              # Current directory is size '0' (like /proc, /sys etc
  fi
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
         *.Z)        uncompress $1   ;;
         *.xz)       xz -d $1        ;;
         *)          echo "'$1' cannot be extracted via extract()" ;;
       esac
   else
      echo "'$1' is not a valid file"
   fi
}

##### TESTS FOR PROMPT STUFF #####
# Test the user type:
if [ ${USER} == "root" ]; then
  ME=${bold}${red}
elif [[ "${USER}" -eq "${LOGNAME}" ]]; then
   if [ ${SUDO_USER} ]; then
      ME=${cyan}
   else
      ME=${green}
   fi
else
  ME=${green}
fi

# Test the connection type:
if [[ -n "${SSH_CONNECTION}" ]]; then
  CNX=${green}
elif [[ -t 0 ]]; then
  CNX=${cyan}
else
  CNX=${lt_red}
fi

PROMPT_HISTORY="history -a"
case ${TERM} in
  *term | rxvt | linux | xterm-256color)
    #PS1='\D{%d-%d %H:%M} ${ME}\u${normal} on ${CNX}\h${normal} in ${disk_color}\w${normal}\n\$ '
    #PS1="[\d \@] [\#] \u@${CNX}\h${normal} ${disk_color}\w${normal}\n--\\$ "
    #PS1="---[\#] ${ME}\u${normal} on ${CNX}\h${normal}\n-(\D{%d%b %H:%M})---> "
    #PS1="[\#] \D{%d%b %H:%M} ${ME}\u${normal}@${CNX}\h${normal}:${disk_color}\w${normal}\n\$ "
    #PS1="---[\#] ${ME}\u${normal} on ${CNX}\h${normal}\n-(\D{%d%b %H:%M})---> "
    #PS1="[\#] \D{%d-%b %H:%M} ${ME}\u${normal} on ${CNX}\h${normal} in ${disk_color}\w${normal}\n"'\$ '
    #PS1=$'\xe2\x94\x8c\xe2\x94\x80[\#] \D{%d-%b %H:%M} ['${ME}'\u'${normal}'@'${CNX}'\h'${normal}$']\xe2\x94\x80\xe2\x94\x80['${disk_color}'\w'${normal}$']\n\xe2\x94\x94\xe2\x94\x80\$ '
    PS1=$'\xe2\x94\x8c\$ \D{%d-%b %H:%M} '${ME}'\u'${normal}' on '${CNX}'\h'${normal}$' in '${disk_color}'\w'${normal}$'\n\xe2\x94\x94\$ '

    # check if fortune and cowsay are executable, then print a small fortune with random character
    if [ -x /usr/games/cowsay -a -x /usr/games/fortune ]; then
      /usr/games/fortune -s | /usr/games/cowsay -f tux
    fi
    ;;
  tmux*)
   PS1="\h \w \$ "
   ;;
  *)
    #PS1="\A \u at \h \w \$"
    PS1="\D{%d-%b %H:%M} ${ME}\u${normal} in ${disk_color}\w${normal}\$ "
  ;;
esac

export JAVA_HOME="/usr/lib/jvm/jdk-11.0.5"
export PATH=${PATH}:/usr/local/scripts:~/scripts:${JAVA_HOME}/bin
export TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
export HISTSIZE=1000000
export HISTFILESIZE=1000000
export HISTIGNORE="&:ls:bg:fg:ll:h"
export HISTTIMEFORMAT="$(echo -e ${bold}${cyan})[%Y%b%d %T]$(echo -e ${normal}) "
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

# lazy old me
alias which='type -a'
alias ..='cd ..'
alias du='du -kh'       # more readable output
alias df='df -h'

# add color and various flags
alias ls='ls -h --time-style=+"%Y-%m-%d %H:%M:%S" --color=auto'
alias lc='ls -ltr'        #  Sort by/show change time,most recent last.
alias lf=lc

# aliases for the lazy person I am
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias mc='mc -x'
alias ports='sudo netstat -tulanp | less'
alias reboot='sudo /sbin/reboot'
alias shutdown='sudo /sbin/poweroff'
alias ipt='sudo iptables -L -n -v --line-numbers'
alias nat='echo -n "ext IP: ";curl -s https://api.ipify.org;echo'
alias weather='curl http://wttr.in'
alias wipe='shred -n5 -u --zero --verbose --remove=wipesync'

# launch tmux with a default screen setup
#alias tmux.main='tmux new-session -s main \; send-keys 'htop' C-m \; split-window -v -p 75 \; split-window -h -p 50 \;'
alias tmux.main='tmux new-session -s main \; split-window -h -p 50 \;'
