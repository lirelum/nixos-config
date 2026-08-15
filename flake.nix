{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      ...
    }@inputs:
    let
      systems = [ "x86_64-linux" ];
      lib = import ./lib.nix {
        inherit
          systems
          nixpkgs
          self
          inputs
          ;
      };
    in
    {
      devShells = lib.forAllSystems (
        system: pkgs: {
          default = pkgs.mkShell {
            packages = with pkgs; [
              nixd
              nixfmt
              statix
              deadnix
              nix-tree
              nix-diff
            ];
          };
        }
      );

      nixosModules = lib.getModules "${self}/modules";

      homeModules = lib.getModules "${self}/home";

      formatter = lib.forAllSystems (system: pkgs: pkgs.nixfmt-tree);

      overlays = import ./overlays { inherit inputs; };

      packages = lib.forAllSystems (system: pkgs: import ./packages { inherit pkgs; });

      nixosConfigurations = {
        miku = lib.mkHost "${self}/hosts/miku";
      };
    };
}
