# 

# Less Colors for Man Pages
#export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
#export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
#export LESS_TERMCAP_me=$'\E[0m'           # end mode
#export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
#export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
#export LESS_TERMCAP_ue=$'\E[0m'           # end underline
#export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

autoload -Uz promptinit
promptinit
prompt adam1

#setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
#bindkey -v

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

export TERM=xterm-256color
#export TERMINFO=~/.terminfo

export ANDROID_SWT="/usr/share/swt-3.7/lib"
export PATH="/opt/android-sdk-update-manager/platform-tools/:${PATH}"

# включить историю команд
setopt APPEND_HISTORY
# # убрать повторяющиеся команды, пустые строки и пр.
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

setopt EXTENDED_GLOB

#autoload -Uz zsh-newuser-install 
#zsh-newuser-install -f

# Use modern completion system
autoload -Uz compinit
compinit

setopt autocd

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2 eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*' menu yes select
zstyle ':completion:*' force-list always

#zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
#zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

zstyle ':completion:*:processes' command 'ps -ax' 
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;32'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*'   force-list always

zstyle ':completion:*:processes-names' command 'ps -e -o comm='
zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:killall:*'   force-list always

# Aliases
alias lla='ls -la'
alias ls='ls --color=auto'
alias grep='grep --colour=auto'
alias -s {avi,mpeg,mpg,mov,m2v,mkv}=vlc
alias -s {mp3}=madplayer
alias -s {pdf}=zathura
#alias -s {odt,doc,sxw,rtf}=openoffice.org
alias -s {odt,doc,docx,sxw,rtf}=libreoffice
autoload -U pick-web-browser
alias -s {html,htm}=firefox

hash -d usl=/usr/src/linux

bindkey -e
#bindkey '^R' history-incremental-search-backward
#bindkey '\e[3~' delete-char # del
#bindkey ';5D' backward-word # ctrl+left
#bindkey ';5C' forward-word #ctrl+right

# Распаковка архивов
# # example: extract file
extract () {
if [ -f $1 ] ; then
case $1 in
*.tar.bz2)   tar xjf $1        ;;
*.tar.gz)    tar xzf $1     ;;
*.bz2)       bunzip2 $1       ;;
*.rar)       unrar x $1     ;;
*.gz)        gunzip $1     ;;
*.tar)       tar xf $1        ;;
*.tbz2)      tar xjf $1      ;;
*.tbz)       tar -xjvf $1    ;;
*.tgz)       tar xzf $1       ;;
*.zip)       unzip $1     ;;
*.Z)         uncompress $1  ;;
*.7z)        7z x $1    ;;
*)        echo "I don't know how to extract '$1'..." ;;
esac
else
echo "'$1' is not a valid file"
fi
}

# Запаковать архив
# example: pk tar file
pk () {
if [ $1 ] ; then
case $1 in
tbz)       tar cjvf $2.tar.bz2 $2      ;;
tgz)       tar czvf $2.tar.gz  $2       ;;
tar)      tar cpvf $2.tar  $2       ;;
bz2)    bzip $2 ;;
gz)        gzip -c -9 -n $2 > $2.gz ;;
zip)       zip -r $2.zip $2   ;;
7z)        7z a $2.7z $2    ;;
*)         echo "'$1' cannot be packed via pk()" ;;
esac
else
echo "'$1' is not a valid file"
fi
}   

insert_sudo () { zle beginning-of-line; zle -U "sudo " }
zle -N insert-sudo insert_sudo
bindkey "^[s" insert-sudo

setopt PROMPT_SUBST

function battery_charge {
  # Battery 0: Discharging, 94%, 03:46:34 remaining
bat_percent=`acpi | awk -F ':' {'print $2;'} | awk -F ',' {'print $2;'} | sed -e "s/\s//" -e "s/%.*//"`
if [ $bat_percent -lt 20 ]; then cl='%F{red}'
elif [ $bat_percent -lt 50 ]; then cl='%F{yellow}'
else cl='%F{green}'
fi
filled=${(l:`expr $bat_percent / 10`::▸:)}
empty=${(l:`expr 10 - $bat_percent / 10`::▹:)}
echo $cl$filled$empty'%F{default}'
}
RPROMPT='[%*] $(battery_charge)'
