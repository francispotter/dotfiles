rm -rf ~/.zdotdir
git clone https://gitlab.com/francispotter/zshrc.git ~/.zdotdir
echo "export ZDOTDIR=$HOME/.zdotdir" > $HOME/.zshenv
ln -s ~/.zdotdir/.editrc ~/.editrc
ln -s ~/.zdotdir/.dyngle.yml ~/.dyngle.yml