# ~/.zshrc

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Basic completion
autoload -Uz compinit
compinit

# Load ZSH plugins (Arch Linux package paths)
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

# Initialize Starship prompt
eval "$(starship init zsh)"

export PATH=$PATH:/home/felix/.spicetify

[ -f "$HOME/.atuin/bin/env" ] && . "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"
eval "$(zoxide init zsh)"
# Custom Aliases
alias ll="eza -la --icons"
alias h="start-hyprland"
alias f="cd /home/felix/fantasy/ && sudo ./fantasy.earthbound.out"
