# FIXME make things more modular later
{
  virtualisation.vmVariant = {
    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = true;

    virtualisation = {
      memorySize = 4096;
      cores = 4;
    };

    services.displayManager.autoLogin.enable = true;
    services.displayManager.autoLogin.user = "autumn";
  };
}