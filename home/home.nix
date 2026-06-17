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

  # GnuPG. programs.gpg installs the gpg binary and manages ~/.gnupg/gpg.conf;
  # services.gpg-agent manages gpg-agent.conf + the launchd agent and points
  # the agent at pinentry-mac for a native (GUI + Keychain) passphrase prompt.
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry_mac;
  };

  # Dotfiles (fish/vim/tmux/ghostty/hammerspoon/git) are linked by the dotfiles
  # repo's own link.sh, run from setup.sh. git identity stays in the local
  # ~/.config/git/config.local that setup.sh generates.
}
