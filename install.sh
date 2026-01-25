# Installs all of DotFiles - Francis Potter on any *nix system
# DESTRUCTIVE!

# Install required packages on Debian-based Linux
if [ -f /etc/debian_version ]; then
    echo "Detected Debian-based Linux. Installing required packages..."
    sudo apt-get update
    sudo apt-get install -y emacs zsh tmux
fi

rm -rf ~/.zdotdir ~/.emacs.d ~/.dotfiles ~/.editrc ~/.tmux.conf
git clone https://gitlab.com/francispotter/dotfiles.git ~/.dotfiles
ln -s ~/.dotfiles/.zdotdir ~/.zdotdir
ln -s ~/.dotfiles/.emacs.d ~/.emacs.d
ln -s ~/.dotfiles/.editrc ~/.editrc
ln -s ~/.dotfiles/.tmux.conf ~/.tmux.conf
echo "export ZDOTDIR=$HOME/.zdotdir" > $HOME/.zshenv
