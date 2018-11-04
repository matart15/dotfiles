" use login Shell instead of interactive shell
" https://github.com/skwp/dotfiles/issues/727
if executable('zsh')
  set shell=/usr/local/bin/zsh\ -l
endif
