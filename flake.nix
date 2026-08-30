{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
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
            packages =
              (with pkgs; [
                nixd
                nixfmt
                statix
                deadnix
                nix-tree
                nix-diff
              ])
              ++ (with self.packages.${system}; [
                diff-system-closure
                update-flake-lock
              ]);
          };
        }
      );

      nixosModules = lib.getModules "${self}/modules";

      homeModules = lib.getModules "${self}/home";

      formatter = lib.forAllSystems (system: pkgs: pkgs.nixfmt-tree);

      overlays = import ./overlays { inherit inputs; };

      packages = lib.forAllSystems (system: pkgs: import ./packages { inherit pkgs; });

      nixosConfigurations = {
        miku = lib.mkHost "${self}/hosts/miku" (
          with self.outputs.nixosModules;
          [
            audio
            bluetooth
            networking
            gnome
            gaming
            users
            virtualisation
            containers
          ]
        );
        teto = lib.mkHost "${self}/hosts/teto" (
          with self.outputs.nixosModules;
          [
            audio
            bluetooth
            networking
            gnome
            gaming
            users
            virtualisation
            containers
          ]
        );
      };

    };
}
