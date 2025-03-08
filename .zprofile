if [ -d ~/.local ]; then
  for script (~/.local/*) source "$script"
fi

eval "$(/opt/homebrew/bin/brew shellenv)"

# Added by `rbenv init` on 2024年 10月17日 木曜日 17時03分50秒 JST
eval "$(rbenv init - --no-rehash zsh)"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
