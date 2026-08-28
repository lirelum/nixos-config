{ inputs, lib, ... }: {
  nix = {
    enable = true;
    channel.enable = false;
    # Registering self would make every source revision change the system closure.
    registry = lib.mapAttrs (_: value: { flake = value; }) (lib.removeAttrs inputs [ "self" ]);
    gc = {
      automatic = true;
      dates = "weekly";
    };
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      trusted-users = [
        "root"
        "@wheel"
      ];
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
  };
}
