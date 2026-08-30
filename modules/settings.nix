{ lib, ... }: {
  options.my.username = lib.mkOption {
    type = lib.types.str;
    description = "Primary user account on the system.";
  };
}
