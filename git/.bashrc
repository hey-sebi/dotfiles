# --- Terminal color settings ---
export COLORTERM=truecolor
export TERM=xterm-256color

# --- Catppuccin Macchiato color palette ---
_reset=$'\[\e[0m\]'
_fg_lavender=$'\[\e[38;2;183;189;248m\]'
_fg_blue=$'\[\e[38;2;138;173;244m\]'
_fg_mauve=$'\[\e[38;2;198;160;246m\]'
_fg_green=$'\[\e[38;2;166;218;149m\]'
_fg_red=$'\[\e[38;2;237;135;150m\]'

# --- QoL ---
shopt -s cdspell 2>/dev/null
shopt -s autocd 2>/dev/null
bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'

# --- Git completion + __git_ps1 ---
for f in \
  /usr/share/git/completion/git-prompt.sh \
  /mingw64/share/git/completion/git-prompt.sh \
  /usr/share/git/completion/git-completion.bash \
  /mingw64/share/git/completion/git-completion.bash
do
  [[ -f "$f" ]] && source "$f"
done

# Status symbol (✓/✗)
__prompt_status() {
  local code=$1
  if (( code == 0 )); then
    printf '%s✓%s' "${_fg_green}" "${_reset}"
  else
    printf '%s✗%s' "${_fg_red}" "${_reset}"
  fi
}

# -------- Performance switches that might have impact on the performance --------
# Modes: fast (default) | rich | counts | off
PROMPT_GIT_MODE=${PROMPT_GIT_MODE:-fast}
__apply_git_mode() {
  case "$PROMPT_GIT_MODE" in
    off)
      unset GIT_PS1_SHOWDIRTYSTATE GIT_PS1_SHOWSTASHSTATE GIT_PS1_SHOWUNTRACKEDFILES GIT_PS1_SHOWUPSTREAM
      ;;
    fast)
      export GIT_PS1_SHOWDIRTYSTATE=0
      export GIT_PS1_SHOWSTASHSTATE=0
      export GIT_PS1_SHOWUNTRACKEDFILES=0
      unset GIT_PS1_SHOWUPSTREAM
      ;;
    rich)
      export GIT_PS1_SHOWDIRTYSTATE=1
      export GIT_PS1_SHOWSTASHSTATE=1
      export GIT_PS1_SHOWUNTRACKEDFILES=1
      # Cheap: show only upstream name, not ahead/behind counts
      export GIT_PS1_SHOWUPSTREAM=name
      ;;
    counts)
      export GIT_PS1_SHOWDIRTYSTATE=1
      export GIT_PS1_SHOWSTASHSTATE=1
      export GIT_PS1_SHOWUNTRACKEDFILES=1
      # Slowest: compute ahead/behind counts
      export GIT_PS1_SHOWUPSTREAM=auto
      ;;
  esac
}
__apply_git_mode

# Change the mode on demand: prompt-git fast|rich|counts|off
prompt-git() { PROMPT_GIT_MODE="$1"; __apply_git_mode; }

# --- Prompt setup ---
if ! command -v starship &>/dev/null; then
  [[ -n "$LOCALAPPDATA" && -d "$LOCALAPPDATA/Microsoft/WinGet/Links" ]] && export PATH="$PATH:$LOCALAPPDATA/Microsoft/WinGet/Links"
fi

if command -v starship &>/dev/null; then
  # In Git Bash, prefer POSIX forward slashes in directory paths
  _starship_cfg="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
  _starship_bash_cfg="${XDG_CONFIG_HOME:-$HOME/.config}/starship-bash.toml"
  if [[ -f "$_starship_cfg" && ( ! -f "$_starship_bash_cfg" || "$_starship_cfg" -nt "$_starship_bash_cfg" ) ]]; then
    sed 's/truncate_to_repo = false/truncate_to_repo = false\nuse_os_path_sep = false/' "$_starship_cfg" > "$_starship_bash_cfg"
  fi
  [[ -f "$_starship_bash_cfg" ]] && export STARSHIP_CONFIG="$_starship_bash_cfg"

  eval "$(starship init bash)"
else
  # Built-in path shortening: keep only last 3 dirs
  PROMPT_DIRTRIM=3
  PROMPT_COMMAND="__make_ps1"
fi

# Ensure the default Git for Windows "MINGW64" prompt doesn't leak in
unset MSYSTEM

# ALIASES
alias ls='ls --color=auto'; alias ll='ls -lah'
alias grep='grep --color=auto'