{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    vim
    eza
    fzf
    ripgrep
    fd
    btop
    fastfetch
    duf
    dust
    procs
    pciutils
    usbutils
    lsof
    lshw
  ];
}