stex integration bash here:
icone:                  E:\cygwin64\Cygwin-Terminal.ico
command line:           E:\cygwin64\bin\mintty.exe -i /Cygwin-Terminal.ico -e /bin/bash -lc 'cd "$@"; exec bash' dummy %curdir
or maybe even better:   E:\cygwin64\bin\mintty.exe -i /Cygwin-Terminal.ico -e /bin/bash -c 'CHERE_INVOKING=1 exec /bin/bash -l'
                        CHERE_INVOKING is handled in /etc/profile. It disables cd ${HOME}

good idea to add noacl to /etc/fstab:
none /cygdrive cygdrive noacl,binary,posix=0,user 0 0

to make completion available on interactive, but no login shell
/etc/bash_completion must exists(and it must be sourced in ~/.bashrc)
