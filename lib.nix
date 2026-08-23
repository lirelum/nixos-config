{
  nixpkgs,
  systems,
  self,
  inputs,
  ...
}:
rec {

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

  getModules =
    dir:
    let
      entries = builtins.readDir dir;
    in
    lib.mapAttrs'
      (
        name: type:
        let
          path = dir + "/${name}";
        in
        if type == "directory" then
          if builtins.pathExists (path + "/default.nix") then
            lib.nameValuePair name path
          else
            lib.nameValuePair name { imports = lib.attrValues (getModules path); }
        else
          lib.nameValuePair (lib.removeSuffix ".nix" name) path
      )
      (
        lib.filterAttrs (
          name: type:
          type == "directory" || (type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix")
        ) entries
      );

  # Walks `dir` recursively, turning every .nix file into a module gated behind
  # `my.<path>.enable`, where <path> is the accumulated directory + file names -
  # e.g. features/users/autumn.nix becomes my.users.autumn.enable. A directory's
  # own default.nix, if present, becomes the toggle for the directory's own name
  # (e.g. features/users/default.nix would become my.users.enable) and is also
  # recorded as a "gate" that everything nested under it defaults to enabling
  # (see mkFeature.nix). No mkFeature call is ever written by hand; the feature
  # files are just bodies.
  getFeatures =
    dir:
    let
      walk =
        gates: prefix: dir:
        let
          entries = builtins.readDir dir;
          hasOwnToggle = prefix != [ ] && builtins.pathExists (dir + "/default.nix");
          ownToggle =
            if hasOwnToggle then
              { ${lib.concatStringsSep "-" prefix} = mkFeature gates prefix (import (dir + "/default.nix")); }
            else
              { };
          childGates = if hasOwnToggle then gates ++ [ prefix ] else gates;
          children = lib.concatMapAttrs (
            name: type:
            if name == "default.nix" then
              { }
            else if type == "directory" then
              walk childGates (prefix ++ [ name ]) (dir + "/${name}")
            else if lib.hasSuffix ".nix" name then
              let
                path = prefix ++ [ (lib.removeSuffix ".nix" name) ];
              in
              { ${lib.concatStringsSep "-" path} = mkFeature childGates path (import (dir + "/${name}")); }
            else
              { }
          ) entries;
        in
        ownToggle // children;
    in
    walk [ ] [ ] dir;

  mkFeature = import ./mkFeature.nix;

  mkHost =
    path:
    lib.nixosSystem {
      modules = builtins.attrValues self.outputs.nixosModules ++ [ path ];
      specialArgs = {
        inherit inputs self;
        inherit (self) outputs;
      };
    };
}
