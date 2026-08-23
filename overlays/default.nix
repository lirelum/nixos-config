{ inputs, ... }: {
  unstable = import ./unstable.nix { inherit (inputs) nixpkgs-unstable; };
}
