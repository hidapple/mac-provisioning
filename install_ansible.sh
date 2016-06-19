#!/bin/sh
which brew >/dev/null 2>&1
if [ $? -ne 0 ]
then
  echo "[INFO] homebrew is not installed."
  echo "[INFO] start to install homebrew."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  echo "[INFO] update homebrew."
  brew update
fi

which ansible >/dev/null 2>&1
if [ $? -ne 0 ]
then
  echo "[INFO] start to install ansible."
  brew install ansible
fi

