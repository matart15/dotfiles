let g:jsx_ext_required = 0 " Allow JSX in normal JS files
let g:javascript_plugin_flow = 1
" let g:ale_javascript_flow_executable = 'node_modules/.bin/flow'
let g:ale_fix_on_save = 1
let g:ale_lint_on_save = 1
let g:ale_lint_on_text_changed = 0
let g:ale_javascript_eslint_executable = 'yarn eslint'

" Load all plugins now.
" Plugins need to be added to runtimepath before helptags can be generated.
packloadall
" Load all of the helptags now, after plugins have been loaded.
" All messages and errors will be ignored.
silent! helptags ALL

" Set this. Airline will handle the rest.
let g:airline#extensions#ale#enabled = 1

let g:ale_linters = {
\   'javascript': ['eslint'],
\   'typescript': ['eslint'],
\   'json': ['eslint'],
\   'graphql': ['eslint'],
\   'php': [],
\}
" Put this in vimrc or a plugin file of your own.
" After this is configured, :ALEFix will try and fix your JS code with ESLint.
let g:ale_fixers = {
\   'javascript': ['eslint'],
\   'typescript': ['eslint'],
\   'json': ['eslint'],
\}

autocmd BufRead,BufNewFile *.es6 setfiletype javascript

" Set this setting in vimrc if you want to fix files automatically on save.
" This is off by default.

set number relativenumber

set foldmethod=indent

function! MyFoldText() " {{{
  let line = getline(v:foldstart)

  let nucolwidth = &fdc + &number * &numberwidth
  let windowwidth = winwidth(0) - nucolwidth - 3
  let foldedlinecount = v:foldend - v:foldstart

  " expand tabs into spaces
  let onetab = strpart('          ', 0, &tabstop)
  let line = substitute(line, '\t', onetab, 'g')

  let line = strpart(line, 0, windowwidth - 2 -len(foldedlinecount))
  let fillcharcount = windowwidth - len(line) - len(foldedlinecount)
  return line . '…' . repeat(" ",fillcharcount) . foldedlinecount . '…' . ' '
endfunction " }}}
set foldtext=MyFoldText()

set foldnestmax=10
set nofoldenable
set foldlevelstart=2
set foldlevel=2
" set fillchars=fold:\
