#!/bin/zsh

echo "syncing dotfiles to ${0:a:h}"

# -sf : create symbolic link, even if it already exists
ln -sf ${0:a:h}/.alacritty.yml $HOME/.alacritty.yml
ln -sf ${0:a:h}/.yabairc $HOME/.yabairc
ln -sf ${0:a:h}/.skhdrc $HOME/.skhdrc
ln -sf ${0:a:h}/.zshrc $HOME/.zshrc
ln -sf ${0:a:h}/.gitconfig $HOME/.gitconfig