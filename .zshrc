# Exa is pretty cool (https://the.exa.website/introduction):
alias ls='exa'
alias ll='exa --header --long --group --git --icons'
alias la='exa --header --long --group --git --icons -a'
alias tree='exa --header --long --group --git --icons --tree'

alias vim='nvim'
alias v='nvim'
alias v-='nvim -'
export EDITOR=nvim

export PROMPT='volume-browser: %~ %# '

export HISTFILE=/root/.local/.zsh_history
export SAVEHIST=10000
export HISTSIZE=10000
setopt HIST_IGNORE_ALL_DUPS
