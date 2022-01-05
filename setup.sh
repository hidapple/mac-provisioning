#!/bin/sh
which brew >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "[INFO] homebrew is not installed."
  echo "[INFO] installing homebrew."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  echo "[INFO] updating homebrew."
  brew update
else
  echo "[INFO] homebrew is already installed."
fi

which ansible >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "[INFO] installing ansible."
  brew install ansible
else
  echo "[INFO] ansible is already installed."
fi

### Execute ansible
echo "[INFO] Executing ansible."
ansible-playbook -vv -i ansible/hosts ansible/macOS-playbook.yml -K

### Prepare .dotfiles
echo "[INFO] Preparing dotfiles."
if [ -d ~/.dotfiles ]; then
  echo "[INFO] .dotfiles already exists."
else
  echo "[INFO] Creating .dotfiles"
  git clone https://github.com/hidapple/dotfiles.git ~/.dotfiles
  sh ~/.dotfiles/link.sh
  source ~/.zshrc
fi

### Create .gitconfig.local
echo "[INFO] Create .gitconfig.local."
if [ -f $XDG_CONFIG_HOME/git/config.local ]; then
  echo "[INFO] git local config file already exists."
else
  echo "name: \c" && read name
  echo "email: \c" && read email
  echo "[user]" > $XDG_CONFIG_HOME/git/config.local
  echo "  name  = $name" >> $XDG_CONFIG_HOME/git/config.local
  echo "  email = $email" >> $XDG_CONFIG_HOME/git/config.local
  echo "[INFO] Created git local config file."
fi

