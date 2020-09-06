export EDITOR='vim'
unamestr=$(uname)
if [[ $unamestr == 'Linux' ]]; then
  platform='linux'
  export ANDROID_HOME=$HOME/Android/Sdk
  export PATH=$PATH:$ANDROID_HOME/tools
  export PATH=$PATH:$ANDROID_HOME/tools/bin
  export PATH=$PATH:$ANDROID_HOME/platform-tools
  export PATH=$PATH:$ANDROID_HOME/emulator
elif [[ $unamestr == 'Darwin' ]]; then
  # eval "$(rbenv init -)"
  export PATH=/usr/local/opt/python/libexec/bin:$PATH # python
  export PATH=/Users/matar/Library/Python/3.6/bin:$PATH
  export PATH=~/.composer/vendor/bin:$PATH
  export ANDROID_HOME=~/Library/Android/sdk
  export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
  # export PATH="/usr/local/opt/node@8/bin:$PATH"
  export NVM_DIR=~/.nvm
  source $(brew --prefix nvm)/nvm.sh

  # flutter
  export PATH="$PATH:~/development/flutter/bin"

  # docker completion
  autoload -Uz compinit && compinit -i
  fpath=(~/.zsh/completion $fpath)

  # The next line updates PATH for the Google Cloud SDK.
  if [ -f '/Users/matar/Downloads/google-cloud-sdk/path.zsh.inc' ]; then source '/Users/matar/Downloads/google-cloud-sdk/path.zsh.inc'; fi

  # The next line enables shell command completion for gcloud.
  if [ -f '/Users/matar/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then source '/Users/matar/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

  export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
fi
