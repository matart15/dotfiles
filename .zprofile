if [ -d ~/.local ]; then
  for script (~/.local/*) source "$script"
fi

# Check for Homebrew on Mac (Apple Silicon) or Linux
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Check if rbenv exists before running init
if command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init - --no-rehash zsh)"
fi

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
