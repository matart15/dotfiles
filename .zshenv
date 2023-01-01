export PATH="/usr/bin:/bin:/usr/sbin:/sbin"
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
export PATH="$HOME/bin:$PATH"

function export_path_if_exists { [[ -d "$1" ]] && export PATH="$1:$PATH" }

# export_path_if_exists "$HOME/.rbenv/bin" && eval "$(rbenv init --no-rehash - zsh)"
# export_path_if_exists /usr/local/share/git-core/contrib/diff-highlight
# export_path_if_exists /usr/local/share/npm/bin && {
#   export NODE_PATH="/usr/local/share/npm/lib/node_modules"
# }

# if [ -d /usr/local/lib/pkgconfig ]; then
#   export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"
# fi

# export LANG='ja_JP.UTF-8'
export EDITOR='vim'
export PAGER='less'
export LESS='-R -g -j10 --no-init --quit-if-one-screen'

disable r