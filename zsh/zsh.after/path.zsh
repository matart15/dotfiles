eval "$(rbenv init -)"
export PATH=/Users/matar/Library/Python/3.6/bin:$PATH
export PATH=~/.composer/vendor/bin:$PATH
export ANDROID_HOME=~/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
export PATH="/usr/local/opt/node@10/bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/matar/Downloads/google-cloud-sdk/path.zsh.inc' ]; then source '/Users/matar/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/matar/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then source '/Users/matar/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
