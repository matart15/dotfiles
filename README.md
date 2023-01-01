# dotfiles

## Install

### Homebrew

```sh
xcode-select --install
sudo xcodebuild -license

sudo mkdir /usr/local
sudo chown -R `whoami` /usr/local
# install homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# install iterm2
brew doctor

git clone https://github.com/kamipo/dotfiles.git
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

### nvm

```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
nvm install 18

```
