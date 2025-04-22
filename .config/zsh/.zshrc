#Fredrik's zsh config
#Remember to make a ~/zsh/plugins/ folder so you can have zsh syntax highlighting. 
#git clone https://github.com/zsh-users/zsh-syntax-highlighting.git #in ~/zsh/plugins
#zsh-completions: git clone git://github.com/zsh-users/zsh-completions.git #in ~/zsh/plugins

setopt prompt_subst
setopt extendedglob       # Extended globbing. Allows using regular expresions with *
setopt nocaseglob         # Case insensitive globbing.
setopt rcexpandparam      # Array expansion with parameters
setopt histignorealldups  # If a new command is a duplicate, remove the older one
setopt autocd             # if only directory path is entered, cd there.

export LC_ALL=en_US.UTF-8

[ -f "$ZDOTDIR/aliasrc" ]  && source "$ZDOTDIR/aliasrc"
[ ! -d "$HOME/.cache/zsh" ] && mkdir "$HOME/.cache/zsh"

fpath=(/home/fredrik/.config/zsh/plugins/zsh-completions/src
       $ZDOTDIR/.zfunc
       $fpath
)

SSH_ENV="$HOME/.ssh/environment"

# Starts ssh-agent by writing the output of ssh-agent into a file determined by $SSH_ENV
# and finally sources the contents of $SSH_ENV to the environment.
ssh_agent_start() {
   ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
   chmod 600 "${SSH_ENV}"
   source "${SSH_ENV}" > /dev/null

   ssh-add -q $HOME/.ssh/id_ed25519
   ssh-add -q $HOME/.ssh/id_ed25519_nordic
}

#if [ $(ps ax | grep "[s]sh-agent" | wc -l) -eq 0 ]; then
if [ -f "${SSH_ENV}" ]; then
   source "${SSH_ENV}" > /dev/null
   ps -ef | grep $SSH_AGENT_PID | grep ssh-agent$ > /dev/null || {
      ssh_agent_start
   }
else
   ssh_agent_start
fi

ps_width=$(($COLUMNS / 4))

autoload -Uz git_ps1
autoload -U branch_info
autoload -U colors && colors
autoload -U compinit && compinit

zstyle ':completion:*' rehash true
zstyle ':completion:*' special-dirs true 
zstyle ':completion:*' menu select 
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-Z}' # Case insensitive tab completion.
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"   # Colored completion (different colors for dirs/files/etc)
zmodload zsh/complist
_comp_options+=(globdots)

PS1='%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%m %{$fg[magenta]%}%~%{$fg[yellow]%}$(git_ps1)$(branch_info)%{$fg[red]%}]%{$reset_color%}$%b '


HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/zhistory
setopt appendhistory

CASE_SENSITIVE="true"

#Vim mode
bindkey -v 

# Binding for reverse search (like in bash)
bindkey '^R' history-incremental-search-backward

#Bindings for vim navigation.
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

#Binding so backspace works "normally"
bindkey -v '^?' backward-delete-char 

#Search history binding
bindkey '^[[5~' history-beginning-search-backward #Page up key
bindkey '^[[6~' history-beginning-search-forward  #Page down key

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor line)
source $ZDOTDIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
. "$HOME/.cargo/env"
