if command -v wmill >/dev/null 2>&1; then
  source <(wmill completions zsh)
fi
export HEADERS=header_key:header_value,header_key2:header_value2
