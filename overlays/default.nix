{ inputs, ... }: {
  unstable = import ./unstable.nix { inherit (inputs) nixpkgs-unstable; };
  local = import ./local.nix { inherit (inputs) packages; };
}
