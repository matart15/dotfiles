
export EDITOR='vim'
unamestr=$(uname)
if [[ $unamestr == 'Linux' ]]; then
  platform='linux'
elif [[ $unamestr == 'Darwin' ]]; then
  export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
fi
