#!/bin/sh
#
# macOS provisioning bootstrap (Nix).
# Installs Nix, applies the nix-darwin config, then links the dotfiles.
#
#   sh setup.sh           # work (default)
#   sh setup.sh work
#   sh setup.sh private
#
set -e

PROFILE="${1:-work}"

# Install Nix if missing.
if ! command -v nix >/dev/null 2>&1; then
  echo "[INFO] Installing Nix (Determinate Systems installer)..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
else
  echo "[INFO] Nix is already installed."
fi

# Lock as the current user. The switch below runs under sudo; locking first
# keeps root from writing (and chowning) flake.lock.
echo "[INFO] Ensuring flake.lock (as current user)..."
nix flake lock

# Apply. On the first run darwin-rebuild isn't on PATH yet, so bootstrap it
# from the nix-darwin flake.
echo "[INFO] Applying nix-darwin configuration: ${PROFILE}"
if ! command -v darwin-rebuild >/dev/null 2>&1; then
  sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ".#${PROFILE}"
else
  sudo darwin-rebuild switch --flake ".#${PROFILE}"
fi

# Make the freshly installed tools (git, etc.) available in this session.
export PATH="/run/current-system/sw/bin:$PATH"

# Clone dotfiles and let the repo link itself via its own link.sh.
DOTFILES="$HOME/.dotfiles"
if [ ! -d "$DOTFILES" ]; then
  echo "[INFO] Cloning dotfiles..."
  git clone https://github.com/hidapple/dotfiles.git "$DOTFILES"
  curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  sh "$DOTFILES/link.sh"
else
  echo "[INFO] ${DOTFILES} already exists (run 'sh ${DOTFILES}/link.sh' to relink)."
fi

# Fast-moving AI CLIs stay out of Nix (nixpkgs lags and they self-update or
# update via npm). Node itself comes from mise, which home-manager installed.
export PATH="/etc/profiles/per-user/$(whoami)/bin:$PATH"
echo "[INFO] Installing node (mise) and npm-global CLIs..."
mise use -g node@lts
mise exec -- npm install -g @openai/codex
if ! command -v claude >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/claude" ]; then
  echo "[INFO] Installing Claude Code (native installer)..."
  curl -fsSL https://claude.ai/install.sh | bash
fi

# git identity stays out of any repo. After link.sh, ~/.config/git is a symlink
# into the dotfiles tree, where config.local is gitignored; the dotfiles'
# git/config [include]s it.
GIT_LOCAL="$HOME/.config/git/config.local"
if [ ! -f "$GIT_LOCAL" ]; then
  echo "[INFO] Creating ${GIT_LOCAL} (kept out of any repo)."
  mkdir -p "$(dirname "$GIT_LOCAL")"
  printf 'git user name : ' ; read -r git_name
  printf 'git user email: ' ; read -r git_email
  {
    echo "[user]"
    echo "	name  = ${git_name}"
    echo "	email = ${git_email}"
  } > "$GIT_LOCAL"
else
  echo "[INFO] ${GIT_LOCAL} already exists."
fi

echo "[INFO] Done."
