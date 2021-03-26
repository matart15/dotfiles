eval "$(rbenv init -)"
export PATH=/Users/matar/Library/Python/3.6/bin:$PATH
export PATH=~/.composer/vendor/bin:$PATH
export ANDROID_HOME=~/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
export PATH="/usr/local/opt/node@10/bin:$PATH"

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
  export PATH="$HOME/.rbenv/bin:$PATH" # ruby
  export PATH=/usr/local/opt/python/libexec/bin:$PATH # python
  export PATH=/Users/matar/Library/Python/3.6/bin:$PATH
  export PATH=~/.composer/vendor/bin:$PATH
  export ANDROID_HOME=~/Library/Android/sdk
  export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

  # flutter
  export PATH="$PATH:/Users/matar/development/flutter/bin"

  # docker completion
  autoload -Uz compinit && compinit -i
  fpath=(~/.zsh/completion $fpath)

  # The next line updates PATH for the Google Cloud SDK.
  if [ -f '/Users/matar/Downloads/google-cloud-sdk/path.zsh.inc' ]; then source '/Users/matar/Downloads/google-cloud-sdk/path.zsh.inc'; fi

  # The next line enables shell command completion for gcloud.
  if [ -f '/Users/matar/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then source '/Users/matar/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

  export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
fi
