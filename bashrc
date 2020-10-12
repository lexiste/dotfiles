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

# load a users alias file if it exists, keeps them out of bashrc
if [ -f ~/.bash_aliases ]; then
   . ~/.bash_aliases
fi

# Some house-keeping
## https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
shopt -s cdspell
shopt -s cmdhist
shopt -s dirspell
shopt -s histappend
shopt -s histverify
#chattr +a ~/.bash_history
set -o vi

##########################################################################
# XXX: Coloured variables
##########################################################################
coltable="/home/todd/scripts/bash/COL_TABLE"
if [[ -f ${coltable} ]]; then
  source ${coltable}
fi

echo -e "It is now: ${COL_GREEN}$(date +%c)${COL_NC}\n"

##### FUNCTIONS #####
function altline () {
   # function that will print every third line green to make reading easier
   awk '{if (NR%2==0){print "\033[32m" $0 "\033[0m"} else{print}}';
}

function _exit() {
  echo -e "${COL_RED}See ya'll later, enjoy!${COL_NC}"
}
trap _exit EXIT

# function that we can call on-demand to enable all commands and output to a log
#  file, useful when performing and audit where you want to log command(s),
#  variables and results for later review and reporting
function rec() {
   # https://www.contextis.com/en/blog/logging-like-a-lumberjack
   #  use something like aha to convert log file to readable HTML format
   test "$(ps -ocommand= -p $PPID | awk '{print $1}')" == 'script' || (script -f $HOME/logs/$(date +"%Y%b%d_%H-%M-%S")_shell.log)
}

# Returns a color according to free disk space in $PWD.
function disk_color() {
  if [ ! -w "${PWD}" ]; then # no write privileges in the current directory
    echo -en ${COL_URG_RED}
  elif [ -s "${PWD}" ] ; then
    local used=$(command df -P "$PWD" | awk 'END {print $5} {sub(/%/,"")}')
    if [ ${used} -gt 95 ]; then
      echo -en ${COL_URG_RED}           # Disk almost full (>95%).
    elif [ ${used} -gt 85 ]; then
      echo -en ${COL_RED}               # Free disk space almost gone.
    else
      echo -en ${COL_GREEN}             # Free disk space is ok.
    fi
  else
    echo -en ${COL_CYAN}                # Current directory is size '0' (like /proc, /sys etc
  fi
}

# function that can extract any standard compressed file type based on extension
function extract () {
   if [ -f $1 ] ; then
      case $1 in
         *.tar)      tar xf $1      ;;
         *.tar.bz2)  tar xjf $1     ;;
         *.tar.gz)   tar xzf $1     ;;
         *.bz2)      bunzip2 $1     ;;
         *.rar)      rar x $1       ;;
         *.gz)       gunzip $1      ;;
         *.tbz2)     tar xjf $1     ;;
         *.tgz)      tar xzf $1     ;;
         *.zip)      unzip $1       ;;
         *.Z)        uncompress $1  ;;
         *.7z)       7z x $1        ;;
         *.xz)       xz -d $1       ;;
         *)          echo "'$1' cannot be extracted via extract()" ;;
       esac
   else
      echo "'$1' is not a valid file"
   fi
}

##### TESTS FOR PROMPT STUFF #####
# Test the user type:
if [ ${USER} == "root" ]; then
  ME=${bold}${COL_RED}
elif [[ "${USER}" -eq "${LOGNAME}" ]]; then
   if [ ${SUDO_USER} ]; then
      ME=${COL_CYAN}
   else
      ME=${COL_GREEN}
   fi
else
  ME=${COL_GREEN}
fi

# Test the connection type:
if [[ -n "${SSH_CONNECTION}" ]]; then
  CNX=${COL_GREEN}
elif [[ -t 0 ]]; then
  CNX=${COL_CYAN}
else
  CNX=${COL_RED}
fi

PROMPT_HISTORY="history -a"
case ${TERM} in
  *term | rxvt | linux | xterm-256color)
    #PS1='\D{%d-%d %H:%M} ${ME}\u${COL_NC} on ${CNX}\h${COL_NC} in ${disk_color}\w${COL_NC}\n\$ '
    #PS1="[\d \@] [\#] \u@${CNX}\h${COL_NC} ${disk_color}\w${COL_NC}\n--\\$ "
    #PS1="---[\#] ${ME}\u${COL_NC} on ${CNX}\h${COL_NC}\n-(\D{%d%b %H:%M})---> "
    #PS1="[\#] \D{%d%b %H:%M} ${ME}\u${COL_NC}@${CNX}\h${COL_NC}:${disk_color}\w${COL_NC}\n\$ "
    #PS1="---[\#] ${ME}\u${COL_NC} on ${CNX}\h${COL_NC}\n-(\D{%d%b %H:%M})---> "
    #PS1="[\#] \D{%d-%b %H:%M} ${ME}\u${COL_NC} on ${CNX}\h${COL_NC} in ${disk_color}\w${COL_NC}\n"'\$ '
    PS1=$'\xe2\x94\x8c \D{%d-%b %H:%M} '${ME}'\u'${COL_NC}'::'${CNX}'\h'${COL_NC}$' '${disk_color}'\w'${COL_NC}$'\n\xe2\x94\x94 '

    # check if fortune and cowsay are executable, then print a small fortune with random character
    if [ -x /usr/games/cowsay -a -x /usr/games/fortune ]; then
      /usr/games/fortune -s | /usr/games/cowsay -f tux
    fi
    ;;
  tmux*)
   PS1="\u:\h \w \$ "
   ;;
  *)
    #PS1="\A \u at \h \w \$"
    PS1="\D{%d-%b %H:%M} ${ME}\u${COL_NC} in ${disk_color}\w${COL_NC}\$ "
  ;;
esac

## some checks for various folders, build string to append to path
if [ -d ~/scripts/bash ]; then
  appendPATH="~/scripts/bash"
fi
if [ -d ~/scripts/python ]; then
  appendPATH=${appendPATH}:"~/scripts/python"
fi

export JAVA_HOME="/usr/lib/jvm/jdk-11.0.5"
export PATH=${PATH}:/usr/local/sbin/:/usr/local/scripts:${JAVA_HOME}/bin:${appendPATH}
export TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
export HISTSIZE=1000000
export HISTFILESIZE=1000000
export HISTIGNORE="&:ls:bg:fg:ll:h"
export HISTTIMEFORMAT="$(echo -e ${COL_BOLD}${COL_CYAN})[%Y%b%d %T]$(echo -e ${COL_NC}) "
export HISTCONTROL=ignoredups
export HOSTFILE=$HOME/.hosts    # Put a list of remote hosts in ~/.hosts
