{
  description = "hidapple's macOS environment (nix-darwin + home-manager)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager }:
  let
    system = "aarch64-darwin";

    # Build one machine's config. extraModules holds profile-specific config.
    mkDarwin = { username, extraModules ? [] }:
      nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit username; };
        modules = [
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
      };
    };
  };
}
