{ config, pkgs, username, ... }:
{
  # Determinate Nix manages /etc/nix/nix.conf, so let nix-darwin not touch Nix.
  nix.enable = false;

  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = username;

  # home-manager reads the user's home dir from here. Metadata only (not in
  # knownUsers), so the existing macOS account is not recreated.
  users.users.${username}.home = "/Users/${username}";

  environment.systemPackages = with pkgs; [
    wget
    git
    lua
    tmux
    vim
    neovim
    openssl
    ripgrep
    fd
    tree
    jq
    fzf
    universal-ctags
    ghq
    gh
  ];

  programs.fish.enable = true;

  # programs.fish.enable does not register fish in /etc/shells on darwin.
  # nix-darwin maps pkgs.fish to the stable /run/current-system path.
  environment.shells = [ pkgs.fish ];

  # Set fish as the login shell. Declarative options don't reliably apply to
  # pre-existing macOS users, so chsh on activation (idempotent, runs as root).
  system.activationScripts.postActivation.text = ''
    fish_path="/run/current-system/sw/bin/fish"
    target_user="${config.system.primaryUser}"
    current_shell=$(/usr/bin/dscl . -read "/Users/$target_user" UserShell 2>/dev/null | awk '{print $2}')
    if [ "$current_shell" != "$fish_path" ]; then
      echo "[activation] changing login shell of $target_user to fish" >&2
      /usr/bin/chsh -s "$fish_path" "$target_user"
    fi
  '';

  # macOS settings
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

  # Pointer speed (0-3, default 1).
  system.defaults.NSGlobalDomain."com.apple.trackpad.scaling" = 2.0;
  system.defaults.CustomUserPreferences.NSGlobalDomain."com.apple.mouse.scaling" = 2.0;

  # Fast key repeat; disable press-and-hold accent menu (better for vim).
  system.defaults.NSGlobalDomain.KeyRepeat = 2;
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 12;
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;

  system.defaults.dock = {
    orientation = "left";
    autohide = true;
    show-recents = false;
    magnification = true; # zoom the icon under the pointer
    tilesize = 36;        # base icon size
    largesize = 54;       # magnified icon size
  };

  system.defaults.finder = {
    AppleShowAllExtensions = true;
    AppleShowAllFiles = true;      # show hidden files
    ShowPathbar = true;
    FXPreferredViewStyle = "Nlsv"; # list view
  };

  # Don't change after the initial setup.
  system.stateVersion = 5;
}
