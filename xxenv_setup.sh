# #!/bin/bash

# set -eux

# if [ ! -d ~/.rbenv ]; then
#   git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
#   ln -nfs $PWD/default-gems ~/.rbenv/default-gems
#   mkdir -p ~/.rbenv/plugins
#   cd ~/.rbenv/plugins
#   git clone https://github.com/rbenv/ruby-build.git
#   git clone https://github.com/rbenv/rbenv-default-gems.git
#   git clone https://github.com/rkh/rbenv-update.git

#   export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

#   # ruby required libssl-dev libreadline6-dev libncurses5-dev libsqlite3-dev
#   rbenv install 2.5.3 --keep
#   rbenv global  2.5.3
#   rbenv rehash
# fi

# if [ ! -d ~/.plenv ]; then
#   git clone https://github.com/tokuhirom/plenv.git ~/.plenv
#   mkdir -p ~/.plenv/plugins
#   cd ~/.plenv/plugins
#   git clone https://github.com/tokuhirom/Perl-Build.git perl-build

#   export PATH="$HOME/.plenv/bin:$PATH"
#   eval "$(plenv init -)"

#   plenv install 5.26.1 -DDEBUGGING=-g --build-dir=~/.plenv/build
#   plenv global  5.26.1
#   plenv install-cpanm
#   plenv rehash
# fi

OS="$(uname)"
case $OS in
'Linux')
  alias ls='ls --color=auto'
  if ! command -v zsh &>/dev/null; then
    sudo apt install zsh -y
    sudo apt install tmux -y
    sudo apt install tmuxinator -y
    # exit
  fi
  ;;
'FreeBSD')
  alias ls='ls -G'
  ;;
'WindowsNT') ;;
'Darwin')
  OS='Mac'
  ;;
*) ;;
esac

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# sudo vi /etc/shells

case uname in
'Linux')
  chsh -s $(which zsh)
  ;;
'FreeBSD') ;;
'WindowsNT') ;;
'Darwin')
  chpass -s /usr/local/bin/zsh
  ;;
*) ;;
esac

# Install PowerLevel10K Theme for Oh My Zsh
git clone https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

# Install ZSH Plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# tmux plugins
# git clone https://github.com/tmux-plugins/tpm ~/dotfiles/.tmux/plugins/tpm
git clone https://github.com/gpakosz/.tmux.git

# nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
nvm install 18
npm i -g nps yarn
# install nps
nps completion $HOME/dotfiles/zsh/zsh.after/nps.zsh >!
