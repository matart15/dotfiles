" use login Shell instead of interactive shell
" https://github.com/skwp/dotfiles/issues/727
if executable('zsh')
  
  if (fpath == expand(vimsettings) . "/yadr-keymap-mac.vim") && uname[:4] ==? "linux"
    set shell=/usr/local/bin/zsh\ -l
  endif

  if (fpath == expand(vimsettings) . "/yadr-keymap-linux.vim") && uname[:4] !=? "linux"
    set shell=/usr/bin/zsh\ -l
  endif
endif
