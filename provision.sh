#!/bin/bash

set -e

echo "🚀 Provisioning local machine..."

echo "🌎 Let's start from Nix..."
if ! command -v nix &> /dev/null; then
    echo "❌ Nix is not installed. installing Nix..."
    curl -fsSL https://install.determinate.systems/nix | sh -s -- install
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
echo "✅ Nix is available."

# flakes
if ! nix --version | grep -q "flake"; then
    echo "🔧 Enabling Nix flakes..."
    mkdir -p ~/.config/nix
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
fi
echo "✅ flakes is available."

# Home Manager
echo "🏠 Applying Home Manager..."
cd "$(dirname "$0")"

if ! command -v home-manager &> /dev/null; then
    echo "📦 Installing Home Manager..."
    nix run home-manager/release-25.05 -- init --switch
else
    echo "🔄 Updating Home Manager..."
    home-manager switch --flake .
fi
echo "✅ home-manager is available."


echo "📝 Preparing dotfiles..."
if [ -d ~/.dotfiles ]; then
  echo "✅ .dotfiles already exists."
else
  echo "Creating .dotfiles"
  git clone https://github.com/hidapple/dotfiles.git ~/.dotfiles
  sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  sh ~/.dotfiles/link.sh
  source ~/.zshrc
  echo "✅ .dotfiles is creatd."
fi

echo "📝 Preparing git local config..."
if [ -f $XDG_CONFIG_HOME/git/config.local ]; then
  echo "✅ git local config file already exists."
else
  echo "name: \c" && read name
  echo "email: \c" && read email
  echo "[user]" > $XDG_CONFIG_HOME/git/config.local
  echo "  name  = $name" >> $XDG_CONFIG_HOME/git/config.local
  echo "  email = $email" >> $XDG_CONFIG_HOME/git/config.local
  echo "✅ Created git local config file."
fi