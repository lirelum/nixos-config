# FIXME make things more modular later
{lib, ...}: {
  virtualisation.vmVariantWithDisko = {
    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = true;

    boot.initrd.availableKernelModules = [
      "virtio_pci"
      "virtio_blk"
      "virtio_scsi"
      "virtio_net"
    ];

    virtualisation = {
      memorySize = 4096;
      cores = 4;
      fileSystems."/home".neededForBoot=true;
    };

    _module.args.disks = lib.mkForce ["/dev/vda"];
    disko.devices.disk.main.imageSize = "30G";


    services.displayManager.autoLogin.enable = true;
    services.displayManager.autoLogin.user = "autumn";
  };
}
