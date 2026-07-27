{
  description = "hidapple's macOS environment (nix-darwin + home-manager)";

  # numtide cache for llm-agents.nix (avoids building herdr etc. from source).
  nixConfig = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # AI coding agent tools (codex etc.), auto-updated daily by numtide.
    # No nixpkgs follows: keeping their pinned nixpkgs keeps the binary cache usable.
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, llm-agents }:
  let
    system = "aarch64-darwin";

    # Build one machine's config. extraModules holds profile-specific config.
    mkDarwin = { username, extraModules ? [] }:
      nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit username; };
        modules = [
          # Exposes pkgs.llm-agents.<tool> from the input's prebuilt packages
          # (pinned to its own nixpkgs, so the numtide binary cache is usable).
          # Upstream removed overlays.default; its shared-nixpkgs overlay would
          # rebuild everything against our nixpkgs instead.
          { nixpkgs.overlays = [ (final: prev: { llm-agents = llm-agents.packages.${system}; }) ]; }

          ./darwin/configuration.nix

          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit username; };
            home-manager.users.${username} = import ./home/home.nix;
          }
        ] ++ extraModules;
      };
  in
  {
    # sudo darwin-rebuild switch --flake .#work    (work Mac)
    # sudo darwin-rebuild switch --flake .#private  (personal Mac)
    darwinConfigurations = {
      work = mkDarwin {
        username = "s-hida";
        extraModules = [ ./darwin/work.nix ];
      };
      private = mkDarwin {
        username = "shoheihida";
        extraModules = [ ./darwin/private.nix ];
      };
    };
  };
}
