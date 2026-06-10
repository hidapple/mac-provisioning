{ pkgs, username, ... }:
{
  # home.username / home.homeDirectory are derived from the nix-darwin
  # users.users.<name> declaration, so they're not set here.

  # Don't change after the initial setup.
  home.stateVersion = "24.11";

  # Install mise. Activation and PATH are handled by the dotfiles' fish config
  # (`mise activate fish`), so don't add a second integration here.
  programs.mise = {
    enable = true;
    enableFishIntegration = false;
  };

  # Dotfiles (fish/vim/tmux/ghostty/hammerspoon/git) are linked by the dotfiles
  # repo's own link.sh, run from setup.sh. git identity stays in the local
  # ~/.config/git/config.local that setup.sh generates.
}
