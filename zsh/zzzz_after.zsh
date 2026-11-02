# Load independent tool modules in dependency-aware order.
for config_name in shell homebrew java android deno cursor maestro node python ruby unity docker git completion keybindings zmv windmill starship; do
  config_file="$HOME/dotfiles/zsh/zsh.after/${config_name}.zsh"
  [[ -f "$config_file" ]] && source "$config_file"
done
unset config_name config_file
