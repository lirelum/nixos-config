{ pkgs }:
{
  diff-system-closure = pkgs.writeShellApplication {
    name = "diff-system-closure";
    runtimeInputs = [
      pkgs.git
      pkgs.nix
    ];
    text = builtins.readFile ../scripts/diff-system-closure.sh;
  };
}
