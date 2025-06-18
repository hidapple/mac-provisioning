{ config, pkgs, ... }:

let
  username = builtins.getEnv "USER";
  homeDir = "/Users/${username}";
in
{
  home.username = username;
  home.homeDirectory = homeDir;
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    wget
    git
    nkf
    lua
    tmux
    vim
    zsh
    openssl
    tree
    jq
    fzf
    ctags
    tig
    direnv
    ghq
    silver-searcher  # ag
    ansifilter
    # kube-ps1
    # Python for Neovim
    python3
    python3Packages.pip
    python3Packages.pynvim 
    # reattach-to-user-namespace works for macOS
  ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
    reattach-to-user-namespace
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "emacs";
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.tmux = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}
