" Open the Ag command and place the cursor into the quotes
nmap ,ag :Ack ""<Left>
nmap ,af :AckFile ""<Left>

let g:ackprg = 'ag --nogroup --nocolor --column'
