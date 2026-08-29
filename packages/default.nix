{ pkgs }:
{
  diff-system-closure = pkgs.writeShellApplication {
    name = "diff-system-closure";
    runtimeInputs = [
      pkgs.git
      pkgs.nix
      pkgs.nix-diff
    ];
    text = builtins.readFile ../scripts/diff-system-closure.sh;
  };

  update-flake-lock = pkgs.writeShellApplication {
    name = "update-flake-lock";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.git
      pkgs.nix
    ];
    text = builtins.readFile ../scripts/update-flake-lock.sh;
  };
}
