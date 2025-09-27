# =============================================================================
# Oh My Zsh Setup
# =============================================================================

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"  # Theme (set to "random" to load a random one)
PATH=$PATH:/home/felix/.cargo/bin

# Uncomment for random theme selection
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Plugins (standard plugins in $ZSH/plugins/, custom in $ZSH_CUSTOM/plugins/)
plugins=(git)

source $ZSH/oh-my-zsh.sh

# =============================================================================
# General Options
# =============================================================================

# Uncomment to use case-sensitive completion
# CASE_SENSITIVE="true"

# Uncomment to use hyphen-insensitive completion (requires case-insensitive off)
# HYPHEN_INSENSITIVE="true"

# Uncomment to disable automatic updates
# zstyle ':omz:update' mode disabled

# Uncomment for automatic updates without prompt
# zstyle ':omz:update' mode auto

# Uncomment to remind when it's time to update
# zstyle ':omz:update' mode reminder

# Uncomment to change update frequency (in days)
# zstyle ':omz:update' frequency 13

# Uncomment to disable magic functions (fixes some paste issues)
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment to disable ls colors
# DISABLE_LS_COLORS="true"

# Uncomment to disable terminal title auto-setting
# DISABLE_AUTO_TITLE="true"

# Uncomment to enable command auto-correction
# ENABLE_CORRECTION="true"

# Uncomment to show red dots while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Uncomment to disable VCS dirty file status
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment to change history timestamp format
# HIST_STAMPS="yyyy-mm-dd"

# Uncomment to change custom Oh My Zsh folder
# ZSH_CUSTOM=/path/to/new-custom-folder

# =============================================================================
# History Settings
# =============================================================================

HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt INC_APPEND_HISTORY

# Enable vi mode
bindkey -v

# =============================================================================
# Editor Setup (optional)
# =============================================================================

# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# =============================================================================
# Autocompletion
# =============================================================================

zstyle :compinstall filename '/home/felix/.zshrc'
autoload -Uz compinit
compinit

# =============================================================================
# Aliases
# =============================================================================

alias ll="exa -la --icons"
alias ll="exa -la --icons"
alias wallpaper='~/.config/hyprland-de/scripts/wallpaper.sh'
alias dl='yt-dlp -P ~/Videos/meme -f "bv*+ba/b" -o "%(title)s.%(ext)s"'
alias gccc="gcc -std=c23 -Wall -Wextra -Wpedantic -Werror -O2"
alias h="hyprland"
# alias zshconfi="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# =============================================================================
# zoxide configuration
# =============================================================================

# Helper: pwd respecting symlinks
function __zoxide_pwd() {
    \builtin pwd -L
}

# Helper: cd wrapper
function __zoxide_cd() {
    \builtin cd -- "$@"
}

# Hook to add new entries to the database
function __zoxide_hook() {
    \command zoxide add -- "$(__zoxide_pwd)"
}

# Initialize zoxide hooks
\builtin typeset -ga precmd_functions
\builtin typeset -ga chpwd_functions
precmd_functions=("${(@)precmd_functions:#__zoxide_hook}")
chpwd_functions=("${(@)chpwd_functions:#__zoxide_hook}")
chpwd_functions+=(__zoxide_hook)

# Doctor check for zoxide config issues
function __zoxide_doctor() {
    [[ ${_ZO_DOCTOR:-1} -ne 0 ]] || return 0
    [[ ${chpwd_functions[(Ie)__zoxide_hook]:-} -eq 0 ]] || return 0

    _ZO_DOCTOR=0
    \builtin printf '%s\n' \
        'zoxide: detected a possible configuration issue.' \
        'Please ensure that zoxide is initialized right at the end of your shell configuration file (usually ~/.zshrc).' \
        '' \
        'If the issue persists, consider filing an issue at:' \
        'https://github.com/ajeetdsouza/zoxide/issues' \
        '' \
        'Disable this message by setting _ZO_DOCTOR=0.' >&2
}

# z and zi commands
function __zoxide_z() {
    __zoxide_doctor
    if [[ "$#" -eq 0 ]]; then
        __zoxide_cd ~
    elif [[ "$#" -eq 1 ]] && { [[ -d "$1" ]] || [[ "$1" = '-' ]] || [[ "$1" =~ ^[-+][0-9]$ ]]; }; then
        __zoxide_cd "$1"
    elif [[ "$#" -eq 2 ]] && [[ "$1" = "--" ]]; then
        __zoxide_cd "$2"
    else
        \builtin local result
        result="$(\command zoxide query --exclude "$(__zoxide_pwd)" -- "$@")" && __zoxide_cd "${result}"
    fi
}

function __zoxide_zi() {
    __zoxide_doctor
    \builtin local result
    result="$(\command zoxide query --interactive -- "$@")" && __zoxide_cd "${result}"
}

function z() {
    __zoxide_z "$@"
}

function zi() {
    __zoxide_zi "$@"
}

# Completions for zoxide
if [[ -o zle ]]; then
    __zoxide_result=''

    function __zoxide_z_complete() {
        [[ "${#words[@]}" -eq "${CURRENT}" ]] || return 0

        if [[ "${#words[@]}" -eq 2 ]]; then
            _cd -/
        elif [[ "${words[-1]}" == '' ]]; then
            __zoxide_result="$(\command zoxide query --exclude "$(__zoxide_pwd || \builtin true)" --interactive -- ${words[2,-1]})" || __zoxide_result=''
            compadd -Q ""
            \builtin bindkey '\e[0n' '__zoxide_z_complete_helper'
            \builtin printf '\e[5n'
            return 0
        fi
    }

    function __zoxide_z_complete_helper() {
        if [[ -n "${__zoxide_result}" ]]; then
            BUFFER="z ${(q-)__zoxide_result}"
            __zoxide_result=''
            \builtin zle reset-prompt
            \builtin zle accept-line
        else
            \builtin zle reset-prompt
        fi
    }

    \builtin zle -N __zoxide_z_complete_helper
    [[ "${+functions[compdef]}" -ne 0 ]] && \compdef __zoxide_z_complete z
fi

# =============================================================================
# yazi shell wrapper
# =============================================================================

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# Initialize zoxide (alternative to all manual config above)
# eval "$(zoxide init zsh)"

