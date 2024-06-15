#!/bin/zsh

echo "running bootstrap.sh"

install() {
    local name=${1}
    local install_command=${2}

    if ! type ${name} &> /dev/null; then
        echo "Installing ${name} with \"${install_command}\""
        eval $install_command
    else
        echo "${name} already installed"
    fi
} 

# base
install "xcode-select" "xcode-select --install"
install "brew" "curl -o /tmp/brew-installer.sh -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh && /bin/bash /tmp/brew-installer.sh"
# may need to configure brew path after this
install "git" "brew install git"
# install "zsh" "brew install zsh" # should already be installed by default
install "code" "brew install --cask visual-studio-code"
install "subl" "brew install --cask sublime-text"

# terminal and shell enhancements
install "alacritty" "brew install --cask alacritty --no-quarantine"
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

# ?
install "nvm" "brew install nvm" 

# unnecessary stuff
# install "spt" "brew install spotify-tui"
# install "spotifyd" "brew install spotifyd"

# background services
brew services start yabai
brew services start skhd
# brew services start spotifyd
