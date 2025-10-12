# Installs all of DotFiles - Francis Potter on any *nix system
# DESTRUCTIVE!
rm -rf ~/.zdotdir ~/.emacs.d ~/.dotfiles ~/.editrc ~/.dyngle.yml ~/.tmux.conf
git clone https://gitlab.com/francispotter/dotfiles.git ~/.dotfiles
ln -s ~/.dotfiles/.zdotdir ~/.zdotdir
ln -s ~/.dotfiles/.emacs.d ~/.emacs.d
ln -s ~/.dotfiles/.editrc ~/.editrc
ln -s ~/.dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/.dotfiles/.dyngle.yml ~/.dyngle.yml
echo "export ZDOTDIR=$HOME/.zdotdir" > $HOME/.zshenv
