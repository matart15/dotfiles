#!/bin/bash
# Powerlevel10k-style truncate_to_unique: shortest unambiguous prefix
# for each non-leaf path segment (among sibling directories).
path=${PWD/#$HOME/\~}
blue=$'\033[38;5;31m'
muted=$'\033[38;5;103m'
bright=$'\033[1;38;5;39m'
reset=$'\033[0m'
unique_prefix() {
  local parent="$1" name="$2" n part other matches
  for ((n=1; n<${#name}; n++)); do
    part=${name:0:n}
    matches=0
    for other in "$parent"/"$part"*/; do
      [[ -d "$other" ]] || continue
      ((matches+=1))
      ((matches>1)) && break
    done
    if ((matches==1)); then printf '%s' "$part"; return; fi
  done
  printf '%s' "$name"
}
if [[ "$PWD" == "$HOME/workplace/github/"* ]]; then
  prefix="$HOME/workplace/github"
  remainder=${PWD#"$prefix"/}
  printf '%s~%s%s/w/gith/%s' "$blue" "$reset" "$muted" "$reset"
  IFS=/ read -r -a segments <<< "$remainder"
  current="$prefix"
  for ((i=0; i<${#segments[@]}; i++)); do
    name=${segments[i]}
    if (( i == ${#segments[@]} - 1 )); then
      printf '%s%s' "$bright" "$name"
    else
      short=$(unique_prefix "$current" "$name")
      printf '%s%s/%s' "$blue" "$short" "$reset"
    fi
    current="$current/$name"
  done
else
  parent=${path%/*}; leaf=${path##*/}
  if [[ "$parent" == "$path" ]]; then printf '%s%s' "$bright" "$path"
  else printf '%s%s/%s%s' "$blue" "$parent" "$bright" "$leaf"; fi
fi
printf '%s' "$reset"
