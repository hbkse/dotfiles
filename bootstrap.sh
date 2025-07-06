#!/bin/bash
set -e

echo "🚀 Bootstrapping development environment..."

# Variables
DEV_DIR="$HOME/dev"
DOTFILES_REPO="https://github.com/hbkse/dotfiles.git"
DOTFILES_DEFAULT_BRANCH="master"
DOTFILES_DIR="$DEV_DIR/dotfiles"

# Install Xcode Command Line Tools if not present
if ! xcode-select -p &> /dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "⏳ Please complete the Xcode Command Line Tools installation and re-run this script."
    exit 1
fi

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for current session and make permanent
    if [[ $(uname -m) == "arm64" ]]; then
        # Apple Silicon
        BREW_PREFIX="/opt/homebrew"
    else
        # Intel
        BREW_PREFIX="/usr/local"
    fi
    
    # Add to current session
    export PATH="$BREW_PREFIX/bin:$PATH"
    
    # Make permanent by adding to shell profile
    SHELL_PROFILE=""
    if [[ $SHELL == *"zsh"* ]]; then
        SHELL_PROFILE="$HOME/.zprofile"
    elif [[ $SHELL == *"bash"* ]]; then
        SHELL_PROFILE="$HOME/.bash_profile"
    fi
    
    if [[ -n "$SHELL_PROFILE" ]]; then
        echo "Adding Homebrew to PATH in $SHELL_PROFILE"
        echo 'eval "$('$BREW_PREFIX'/bin/brew shellenv)"' >> "$SHELL_PROFILE"
    fi
    
    # Initialize Homebrew for current session
    eval "$($BREW_PREFIX/bin/brew shellenv)"
    
    echo "✅ Homebrew installed and added to PATH"
else
    echo "✅ Homebrew already installed"
fi

# Verify brew is working
if command -v brew &> /dev/null; then
    echo "🍺 Homebrew version: $(brew --version | head -n1)"
else
    echo "❌ Error: brew command not found after installation"
    exit 1
fi

# Create dev directory
if [ ! -d "$DEV_DIR" ]; then
    echo "📁 Creating dev directory at $DEV_DIR"
    mkdir -p "$DEV_DIR"
else
    echo "✅ Dev directory already exists at $DEV_DIR"
fi

# Clone dotfiles repository into dev directory
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "📥 Cloning dotfiles repository..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    echo "✅ Dotfiles cloned to $DOTFILES_DIR"
else
    echo "✅ Dotfiles directory already exists at $DOTFILES_DIR"
    echo "🔄 Pulling latest changes..."
    cd "$DOTFILES_DIR"
    git pull origin $DOTFILES_DEFAULT_BRANCH
    cd -
fi

# Change to dotfiles directory for the rest of the setup
cd "$DOTFILES_DIR"
echo "➡️ Changing working directory to dotfiles repository $DOTFILES_DIR..."

# Install packages from Brewfile
if [ -f "Brewfile" ]; then
    echo "🍺 Getting latest packages..."
    brew update
    echo "🍺 Installing packages from Brewfile..."
    brew bundle || echo "⚠️  Some packages failed - continuing anyway"
    echo "✅ Brewfile processing complete"
else
    echo "⚠️  Brewfile not found in $DOTFILES_DIR"
fi

# Handle accessibility permissions for both yabai and skhd
if command -v yabai &> /dev/null || command -v skhd &> /dev/null; then
    echo ""
    echo "🔒 ACCESSIBILITY PERMISSIONS REQUIRED"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Both yabai and skhd need accessibility permissions to work."
    echo ""
    echo "📱 Please do the following:"
    echo "   1. Open System Settings.app"
    echo "   2. Go to Privacy & Security → Accessibility"
    echo "   3. Click the + button (bottom left)"
    
    if command -v yabai &> /dev/null; then
        echo "   4. Add: /opt/homebrew/bin/yabai"
        echo "   Hint: Press CMD + SHIFT + G in Finder to folder search /opt/homebrew"
        echo ""
    fi
    
    if command -v skhd &> /dev/null; then
        echo "   5. Add: /opt/homebrew/bin/skhd"
        echo "   Hint: Press CMD + SHIFT + G in Finder to folder search /opt/homebrew"
        echo ""
        echo "🔐 ALSO for skhd:"
        echo "   • Disable 'Secure Keyboard Entry' in any terminal apps"
        echo "   • Check Terminal → Secure Keyboard Entry (uncheck it)"
        echo "   • Check other terminals like Alacritty preferences"
        echo ""
    fi
    
    read -p "Press ENTER when you've completed the accessibility setup..." -r
    echo ""
fi

# Install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "📦 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Sync dotfiles to their proper locations
if [ -f "sync.sh" ]; then
    echo "🔄 Syncing dotfiles to system locations..."
    chmod +x sync.sh
    ./sync.sh
    echo "✅ Dotfiles synced successfully"
else
    echo "⚠️  sync.sh not found in $DOTFILES_DIR"
fi

# Start services with proper restart handling
echo "🚀 Starting services..."

# Start yabai
if command -v yabai &> /dev/null; then
    echo "Starting yabai..."
    if yabai --start-service 2>/dev/null; then
        echo "✅ yabai started successfully"
    elif brew services start yabai 2>/dev/null; then
        echo "✅ yabai service started"
    else
        echo "⚠️  yabai failed to start - check accessibility permissions"
    fi
fi

# Start skhd
if command -v skhd &> /dev/null; then
    echo "Starting skhd..."
    if skhd --start-service 2>/dev/null; then
        echo "✅ skhd started successfully"
    elif brew services start skhd 2>/dev/null; then
        echo "✅ skhd service started"
    else
        echo "⚠️  skhd failed to start - check accessibility permissions"
    fi
    echo "💡 If skhd shortcuts don't work, check 'Secure Keyboard Entry' is disabled"
fi

# Force Spotlight to reindex Applications folder
echo "🔍 Updating Spotlight index..."
sudo mdutil -E /Applications
echo "✅ Done updating Spotlight index"

# Exit message
echo ""
echo "🎉 BOOTSTRAP COMPLETE 🎉"
echo "🚀 POSSIBLE NEXT STEPS 🚀"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1️⃣  RESTART YOUR TERMINAL"
echo ""
echo "2️⃣  TEST KEYBOARD SHORTCUTS"
echo ""
echo "3️⃣  CLEAN UP YOUR DOCK"
echo "   • Remove default apps you don't use"
echo "   • Add newly installed apps: Alacritty, VS Code, Discord, Spotify"
echo "   • Right-click apps → Options → Keep in Dock"
echo ""
echo "4️⃣  SIGN INTO ACCOUNTS"
echo "   • Sync your google chrome"
echo ""
echo "5️⃣  SET UP GIT"
echo "   • git config --global user.email 'your.email@example.com'"
echo ""
echo "🔧 TROUBLESHOOTING:"
echo "   • If yabai/skhd shortcuts don't work: Check System Settings → Accessibility"
echo "   • If Alacritty doesn't appear in Spotlight: sudo mdimport /Applications/Alacritty.app"
echo "   • If brew commands fail: Check PATH with 'echo \$PATH'"
echo "   • To restart window manager: yabai --restart-service && skhd --restart-service"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""