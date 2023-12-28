# export ANDROID_HOME=~/Library/Android/sdk
# export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
# export PATH="/usr/local/opt/node@10/bin:$PATH"

export JAVA_HOME="/Applications/Android Studio.app/Contents/jre/Contents/Home"
export PATH=$JAVA_HOME/bin:$PATH

unamestr=$(uname)
if [[ $unamestr == 'Darwin' ]]; then

fi

export PATH=$PATH:/snap/bin # needed for code command

# deno
export DENO_INSTALL="/home/matar/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

export ANDROID_HOME="/home/matar/Android/Sdk"

# pnpm
export PNPM_HOME="/Users/matar/Library/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export PATH="$PATH":"$HOME/.maestro/bin"
