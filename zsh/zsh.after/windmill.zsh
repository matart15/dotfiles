#!/bin/bash

# Check if wmill is installed
if ! command -v wmill &>/dev/null; then
  echo "wmill is not installed. Installing windmill-cli..."
  npm install -g windmill-cli
  source <(wmill completions zsh)
fi
export HEADERS=header_key:header_value,header_key2:header_value2
