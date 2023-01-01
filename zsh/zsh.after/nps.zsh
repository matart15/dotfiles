###-begin-nps-completions-###
#
# yargs command completion script
#
# Installation: nps completion >> ~/.zshrc
#    or nps completion >> ~/.zsh_profile on OSX.
#
_nps_yargs_completions()
{
  local reply
  local si=$IFS
  IFS=$'
' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" nps --get-yargs-completions "${words[@]}"))
  IFS=$si
  _describe 'values' reply
}
compdef _nps_yargs_completions nps
###-end-nps-completions-###

