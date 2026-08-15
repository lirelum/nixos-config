{ nixpkgs, systems, self, inputs, ... }: rec {
  
  lib = nixpkgs.lib;

  forAllSystems = 
    f:
    lib.genAttrs systems (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      f system pkgs
    );
    
    getModules = dir:
    let
      entries = builtins.readDir dir;
    in
    lib.mapAttrs' (name: type: 
      let path = dir + "/${name}"; in 
      if type == "directory" then
        if builtins.pathExists (path + "/default.nix")
        then lib.nameValuePair name path
        else lib.nameValuePair name { imports = lib.attrValues (getModules path); }
      else
        lib.nameValuePair (lib.removeSuffix ".nix" name) path
    ) (lib.filterAttrs (name: type:
      type == "directory" || (type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix") 
    ) entries);
    
    mkHost = path: lib.nixosSystem {
      modules = builtins.attrValues self.outputs.nixosModules ++ [ path ];
      specialArgs = {inherit inputs self; inherit (self) outputs;};
    };
}
