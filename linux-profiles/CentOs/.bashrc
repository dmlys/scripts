# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

#turn off Ctrl+S, Ctrl+Q termianl stop
stty -ixon

# User specific aliases and functions
alias l="ls -lhF"
alias ll="ls -lhFA"
alias nano="nano -z"

# auto less color support
export LESS='-R'

if [ "$TERM" = "xterm" ]; then
    #for ncurses drawing
    export NCURSES_NO_UTF8_ACS=1
    #same for tilde editor
    export T3WINDOW_OPTS=acs=utf8
fi

