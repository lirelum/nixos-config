{ pkgs, ... }: {
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
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # Base C/C++ runtime & system dependencies
      stdenv.cc.cc.lib
      zlib
      glibc
      util-linux # libuuid

      # Security & Networking
      openssl
      curl
      libkrb5

      # Desktop & Graphics (OpenGL/Vulkan for renderers/GUI extensions)
      libGL
      xorg.libX11
      xorg.libXcursor
      xorg.libXrandr
      xorg.libXi
      wayland

      # Internationalization & Encoding
      icu
      libxml2

      # Audio & System Interoperability
      alsa-lib
      fontconfig
      freetype
    ];
  };
}
