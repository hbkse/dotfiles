#!/bin/zsh

echo "running bootstrap.sh"

install() {
    local name=${1}
    local install_command=${2}

    if ! type ${name} &> /dev/null; then
        echo "Installing ${name}"
        eval $install_command
    else
        echo "${name} already installed"
    fi
} 

# base
install "xcode-select" "xcode-select --install"
install "brew" "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
install "git" "brew install git"
# install "zsh" "brew install zsh" # should already be installed by default
install "code" "brew install --cask visual-studio-code"

# terminal and shell enhancements
install "alacritty" "brew install --cask alacritty"
install "tmux" "brew install tmux"
if ! [ -d ~/.oh-my-zsh ]; then
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
 else
 	echo "oh-my-zsh already installed"
fi

# window manager
install "yabai" "brew install koekeishiya/formulae/yabai"
install "skhd" "brew install koekeishiya/formulae/skhd"

# colorful stuff
install "lsd" "brew install lsd"
brew tap homebrew/cask-fonts
brew install --cask font-hack-nerd-font
brew install --cask font-jetbrains-mono-nerd-font
install "bat" "brew install bat"
install "diff-so-fancy" "brew install diff-so-fancy"