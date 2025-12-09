# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt autocd extendedglob
unsetopt beep
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/felix/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Atuin history integration for zsh
eval "$(atuin init zsh)"
eval "$(zoxide init zsh)"

# Load Spaceship prompt
if [ -f /usr/lib/spaceship-prompt/spaceship.zsh ]; then
  source /usr/lib/spaceship-prompt/spaceship.zsh
fi

# Aliases
alias ll="eza -la --icons"

# Variables
