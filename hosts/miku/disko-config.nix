{
  disks ? [ "/dev/vda" ],
  ...
}:
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = builtins.elemAt disks 0;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            name = "ESP";
            size = "2G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/efi";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "@".mountpoint = "/";
                "@home" = {
                  mountOptions = [ "compress=zstd" ];
                  mountpoint = "/home";
                };
                "@nix" = {
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                  mountpoint = "/nix";
                };
                "@swap" = {
                  mountpoint = "/.swapvol";
                  swap = {
                    swapfile.size = "8G";
                    swapfile.path = "swapfile";
                  };
                };
                "@var_log" = {
                  mountOptions = [ "compress=zstd" "noatime" ];
                  mountpoint = "/var/log";
                };
              };
            };
          };
        };
      };
    };
  };
}
