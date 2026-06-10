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

    # Build one machine's config. work/private only differ by username for now;
    # add a per-profile module to `modules` here if they ever diverge.
    mkDarwin = username:
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
        ];
      };
  in
  {
    # sudo darwin-rebuild switch --flake .#work    (work Mac)
    # sudo darwin-rebuild switch --flake .#private  (personal Mac)
    darwinConfigurations = {
      work    = mkDarwin "s-hida";
      private = mkDarwin "hidapple";
    };
  };
}
