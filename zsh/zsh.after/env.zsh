
export EDITOR='vim'
export OPENFAAS_URL="157.230.65.49:8080"
unamestr=$(uname)
if [[ $unamestr == 'Linux' ]]; then
  platform='linux'
elif [[ $unamestr == 'Darwin' ]]; then
  export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
fi
