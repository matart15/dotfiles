" Open the Ack command and place the cursor into the quotes
nmap ,ag :Ack ""<Left>
nmap ,af :AckFile ""<Left>

if executable('ag')
  let g:ackprg = 'ag --nogroup --nocolor --column --ignore node_modules'
endif

" test ackfile
