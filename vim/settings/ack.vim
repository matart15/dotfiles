" Open the Ack command and place the cursor into the quotes
nmap <Leader>ag :Ack "<cword>"<cr>
vnoremap <Leader>af y:AckFile <C-r>=fnameescape(@")<CR><CR>
vnoremap <Leader>as y:Ack <C-r>=fnameescape(@")<CR><CR>

if executable('ag')
  let g:ackprg = 'ag --nogroup --nocolor --column --ignore node_modules'
endif

" test ackfile
