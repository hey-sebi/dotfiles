# dotfiles
Contains configuration and setup files for my personal use. Use what you want, but use it at your personal risk.

## Setup
To use the dotfiles we symlink them to the home directory using GNU stow.<br>
There is a script which does that for us: `stow.sh`. Run this file from the repository root directory (where it is located).

In case you need to remove the symlinks, use `unstow.sh`.

## Contents

### Tmux configuration

For information about Tmux see https://github.com/tmux/tmux/wiki

*Needs the [Tmux plugin manager](https://github.com/tmux-plugins/tpm) to be installed.*

This config is inspired by https://www.youtube.com/watch?v=DzNmUNvnB04 which is also a great tutorial on how to set things up.

### Shell aliases

Contains bash/zsh aliases (should work in both shells). It should be integrated in a .bashrc or .zshrc like so:
```
  . ~/.shell-aliases.sh
```

