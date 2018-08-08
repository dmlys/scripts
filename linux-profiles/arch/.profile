# add local bin directories if they exists
if [ -d ~/.local/bin ] && [ -z $(echo $PATH | grep -o $HOME/.local/bin) ]; then
    PATH=~/.local/bin:$PATH
fi

if [ -d ~/bin ] && [ -z $(echo $PATH | grep -o $HOME/bin) ]; then
    PATH=$HOME/bin:$PATH
fi
