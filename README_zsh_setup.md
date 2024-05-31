# Install zsh & setup configuration

This readme describes an *initial* setup from scratch for zsh, oh-my-zsh, powerlevel10k theme and some plugins.

The dotfiles (`.zshrc` and `.p10k.zsh`) with my preferred settings are contained in the `zsh` directory.

## Install zsh

If zsh is not yet installed.. install it e.g. with the package manager of your distro.

## Install oh-my-zsh

Setup: run the install script via:

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Install Nerd Font

Some themes need a nerd font for some symbols. I use the *Meslo* Nerd Font.

Setup:

Download and move the Meslo Nerd Fonts to the `~/.fonts` folder. Create one if you don't already have one:

```
mkdir -p ~/.fonts && cd ~/.fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Meslo.zip
unzip Meslo.zip && rm Meslo.zip
```

We now need to register the fonts with the OS:

```
sudo apt install fontconfig
fc-cache -fv
```

## Install Powerlevel10k Theme

```
git clone https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
```

Set the theme in the .zshrc:
```
ZSH_THEME="powerlevel10k/powerlevel10k"
```

Afterwards restart the terminal and run
```
p10k configure
```

## Plugins

```
git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/Pilaton/OhMyZsh-full-autoupdate.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/ohmyzsh-full-autoupdate
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
```

## Install zoxide

This is not related to zsh, but if you want to use the zoxide plugin, you need to install zoxide itself first:

```
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
```
