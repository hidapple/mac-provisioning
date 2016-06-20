#!/bin/sh
which brew >/dev/null 2>&1
if [ $? -ne 0 ]
then
  echo "[INFO] homebrew is not installed."
  echo "[INFO] installing homebrew."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  echo "[INFO] updating homebrew."
  brew update
else
  echo "[INFO] homebrew is already installed."
fi

which ansible >/dev/null 2>&1
if [ $? -ne 0 ]
then
  echo "[INFO] installing ansible."
  brew install ansible
else
  echo "[INFO] ansible is already installed."
fi

### Execute ansible
ansible-playbook -vv -i hosts macOS-playbook.yml

### Prepare .dotfiles
dir=~/.dotfiles
if [ -d $dir ]
then
  echo "[INFO] .dotfiles already exists."
else
  echo "[INFO] Creating .dotfiles"
  git clone https://github.com/hidapple/dotfiles.git ~/.dotfiles
  sh ~/.dotfiles/install.sh
  echo "[INFO] Cloning Neobundle."
  mkdir -p .vim/bundle
  git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
fi

