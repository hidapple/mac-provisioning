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
ansible-playbook -vv -i hosts macOS-playbook.yml -K

### Prepare .dotfiles
echo "[INFO] Preparing dotfiles."
if [ -d ~/.dotfiles ]; then
  echo "[INFO] .dotfiles already exists."
else
  echo "[INFO] Creating .dotfiles"
  git clone https://github.com/hidapple/dotfiles.git ~/.dotfiles
  sh ~/.dotfiles/link.sh
fi

### Create .gitconfig.local
echo "[INFO] Create .gitconfig.local."
if [ -f ~/.gitconfig.local ]; then
  echo "[INFO] .gitconfig.local already exists."
else
  echo "name: \c" && read name
  echo "email: \c" && read email
  echo "[user]" > ~/.gitconfig.local
  echo "  name  = $name" >> ~/.gitconfig.local
  echo "  email = $email" >> ~/.gitconfig.local
  echo "[INFO] Created ~/.gitconfig.local."
fi

