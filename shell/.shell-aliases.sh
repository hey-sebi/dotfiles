# ----------------------------------------------------------------
#  GIT & Co
# ----------------------------------------------------------------

# Commits with a timestamp of 12 hours in the future
alias future-commit='git commit --date "$(date -d +12hours)"'


# ----------------------------------------------------------------
#  Editors
# ----------------------------------------------------------------

# Doom emacs' 'doom' executable
alias doom='~/.config/emacs/bin/doom'
# NeoVim from appimage
alias nvim='~/nvim.appimage'


# ----------------------------------------------------------------
#  Mixed
# ----------------------------------------------------------------

# Use python3 per default
alias python='python3'

# Run tmux with config file from our dotfiles
alias tmux='tmux -f /personal/dotfiles/tmux/.tmux.conf'