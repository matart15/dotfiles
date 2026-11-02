# dotfiles

## Install

### Homebrew

```sh
xcode-select --install
sudo xcodebuild -license

sudo mkdir /usr/local
sudo chown -R `whoami` /usr/local

# install iterm2
brew doctor

# this code should be inside ~/dotfiles folder
cd ~ && git clone https://github.com/matart15/dotfiles.git
cd dotfiles

./brewfile.sh
./dotsetup.sh
./xxenv_setup.sh

```

### Vscode

Update VSCode Terminal Font (Optional)

```json
"terminal.integrated.fontFamily": "MesloLGS NF"
```

### Change iTerm2 Colors to My Custom Theme

```sh
curl https://raw.githubusercontent.com/josean-dev/dev-environment-files/main/coolnight.itermcolors --output ~/Downloads/coolnight.itermcolors
```


### Starship prompt (macOS / Linux / FreeBSD)

The tracked configuration is `starship/starship.toml`; the path formatter is
`starship/starship-path.sh`. `dotsetup.sh` links the configuration to
`~/.config/starship.toml`, and `xxenv_setup.sh` installs Starship if missing
(Homebrew on macOS, the official user-local installer on Linux, `pkg` on FreeBSD).
Run the existing setup in order: `./dotsetup.sh`, then `./xxenv_setup.sh`.
Starship starts from `zsh/zsh.after/starship.zsh` when installed.
