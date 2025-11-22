# =============================================================================
#  zsh configuration
# =============================================================================

export PATH=$HOME/bin:/usr/local/bin:$PATH

# -----------------------------------------------------------------------------
#  Keybindings
# -----------------------------------------------------------------------------
# bindkey -e # emacs mode
bindkey -v # vim mode
bindkey '^n' history-search-forward
bindkey '^p' history-search-backward
# bindkey '^[[Z' autosuggest-accept  # shift + tab

# -----------------------------------------------------------------------------
#  Command history (e.g. for reverse search / zsh-autosuggestions)
# -----------------------------------------------------------------------------
HISTSIZE=5000
HISTFILE=~/.zsh_history
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups
# prevent commands starting with space to be memorized:
setopt hist_ignore_space

# -----------------------------------------------------------------------------
#  Autosuggestion settings
# -----------------------------------------------------------------------------

# Allow lower case to also complete upper case to be more fuzzy
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# use colors configured for 'ls' (like folder colors etc)
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# -----------------------------------------------------------------------------
#  Language/locale settings
# -----------------------------------------------------------------------------

export LANGUAGE="en_US:en"
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"


# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='nvim'
fi

# -----------------------------------------------------------------------------
#  Aliases
# -----------------------------------------------------------------------------

# Personal shell aliases
if [ -f ~/.shell-aliases.sh ]; then
    . ~/.shell-aliases.sh
else
    echo "Personal shell aliases not available"
fi

# Work shell aliases
if [ -f ~/dev/work/utility_scripts/scripts/bash_aliases.sh ]; then
    . ~/dev/work/utility_scripts/scripts/bash_aliases.sh
else
    echo "Work shell aliases not available"
fi

# -----------------------------------------------------------------------------
#  Enable truecolor support
# -----------------------------------------------------------------------------
export COLORTERM=truecolor

# -----------------------------------------------------------------------------
#  Add utility scripts to PATH
# -----------------------------------------------------------------------------

if [ -d "$HOME/dev/work/utility_scripts/scripts" ] ; then
    PATH="$HOME/dev/work/utility_scripts/scripts:$PATH"
    alias rid='run-in-docker.sh'
fi

# -----------------------------------------------------------------------------
#  Add locally installed tools to PATH
# -----------------------------------------------------------------------------
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# -----------------------------------------------------------------------------
#  Starship prompt
# -----------------------------------------------------------------------------
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi


# -----------------------------------------------------------------------------
#  zoxide
# -----------------------------------------------------------------------------
eval "$(zoxide init zsh)"

# -----------------------------------------------------------------------------
#  fzf
# -----------------------------------------------------------------------------
# Set up fzf key bindings and fuzzy completion
# source <(fzf --zsh) TODO
