#!/bin/sh
which brew >/dev/null 2>&1
if [ $? -ne 0 ]
then
  echo "[INFO] homebrew is not installed."
  echo "[INFO] installing homebrew."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  echo "[INFO] updating homebrew."
  brew update
fi

which ansible >/dev/null 2>&1
if [ $? -ne 0 ]
then
  echo "[INFO] installing ansible."
  brew install ansible
fi

### Execute ansible
ansible-playbook -vv -i hosts macOS-playbook.yml

