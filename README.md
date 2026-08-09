# dotfiles
Contains configuration and setup files for my personal use. Use what you want, but use it at your personal risk.

## Setup

### Windows (PowerShell)
Run the PowerShell linking script from the root of the repository:
```pwsh
.\Link-Dotfiles.ps1
```
Options:
- `-DryRun`: Preview what links will be created without making changes.
- `-Verbose`: Print detailed path info.

This creates symlinks / directory junctions for Wezterm (`~/.config/wezterm`), PowerShell profile, Starship config, Git bash config, and shell aliases.

### Linux / macOS (GNU Stow)
To symlink dotfiles using GNU Stow, run from the root of the repository:
```bash
./stow.sh
```
To remove the symlinks:
```bash
./unstow.sh
```

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

