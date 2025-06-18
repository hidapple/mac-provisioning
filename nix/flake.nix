{
    description = "Nix Home Environment";
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
        home-manager.url = "github:nix-community/home-manager/release-25.05";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";
    };

    outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
        username = builtins.getEnv "USER";
        system = "aarch64-darwin";
    in {
        homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs { inherit system; };
            modules = [ ./home.nix ];
        };
    };
}