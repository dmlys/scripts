alias sudo='sudo '

alias ls="ls $COLOR_OPTS --human-readable"

# For some basic commands(quite a lot actually, including ls) bash completion is implemented by invoking command with --help argument,
# parsing result, extracting command line options and returning them. All this is implemented in function _longopt, complete -p ls returns complete -F _longopt ls
# 
# something like                         here our alias would be
# COMPREPLY=( $( compgen -W "$( LC_ALL=C $1 --help 2>&1 | command sed -ne 's/.*\(--[-A-Za-z0-9]\{1,\}=\{0,1\}\).*/\1/p' | sort -u )" -- "$cur" ) )
# 
# Problem is bash aliases are visible and expanded at the moment of function difinition, that code line above just would not work for aliases
# instead just make thme functions, those would work

function ll { ls -lFA "$@" ; }
function l  { ls -lF "$@"  ; }
function l. { ls -A "$@"   ; }

# add bash_completion for aliases
# complete -p ls
complete -F _longopt ll
complete -F _longopt l
complete -F _longopt l.

# still define them as aliases, so alias combining would work
# sudo l /etc/...
alias ll='ls -lFA'
alias l='ls -lF'
alias l.='ls -A'
