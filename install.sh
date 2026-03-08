# Installs all of DotFiles - Francis Potter on any *nix system
# DESTRUCTIVE!

# Install required packages on Debian-based Linux
if [ -f /etc/debian_version ]; then
    echo "Installing for Debian..."
    sudo apt-get update
    sudo  DEBIAN_FRONTEND=noninteractive apt-get install -y emacs zsh tmux
fi

# Install required packages on MacOS
if [ "$(uname)" = "Darwin" ]; then
    echo "Installing for MacOS..."
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install emacs zsh tmux
fi

rm -rf ~/.zdotdir ~/.emacs.d ~/.dotfiles ~/.editrc ~/.tmux.conf
git clone https://lab.shelbourne.ca/ops/dotfiles.git ~/.dotfiles
ln -s ~/.dotfiles/.zdotdir ~/.zdotdir
ln -s ~/.dotfiles/.emacs.d ~/.emacs.d
ln -s ~/.dotfiles/.editrc ~/.editrc
ln -s ~/.dotfiles/.tmux.conf ~/.tmux.conf
echo "export ZDOTDIR=$HOME/.zdotdir" > $HOME/.zshenv

if [ -f /etc/debian_version ]; then
  sudo usermod --shell /bin/zsh $(whoami)
fi

if [ "$(uname)" = "Darwin" ]; then
  sudo chsh -s /bin/zsh $(whoami)
fi

exec zsh