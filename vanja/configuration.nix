# NixOS configuration for a Toshiba Satellite L15-B1330
# (Intel Celeron N2840 "Bay Trail", Intel HD graphics, 2-4 GB RAM, 32 GB eMMC, UEFI).
#
# Accounts:
#   admin - normal account with sudo, console only (log in on tty2: Ctrl+Alt+F2).
#   vanja - auto-logged-in on tty1 straight into a menu of allowed programs.
#
# Install: boot the NixOS installer, partition the eMMC (/dev/mmcblk0: GPT with
# an EFI system partition + ext4 root), mount on /mnt, run
# `nixos-generate-config --root /mnt`, copy this file and vanja-menu.nix into
# /mnt/etc/nixos/ and run `nixos-install`.
#
# Test in a VM on any NixOS host (from the flake root):
#   nixos-rebuild build-vm --flake .#toshiba && ./result/bin/run-toshiba-vm
{ lib, pkgs, ... }:

{
  # hardware-configuration.nix is generated on the laptop at install time; it
  # is absent when building the VM from the repo.
  imports = [
    ./vanja-menu.nix
  ]
  ++ lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix;

  # Only applies to `nixos-rebuild build-vm`; no effect on the real machine.
  virtualisation.vmVariant.virtualisation = {
    memorySize = 3072; # about the laptop's RAM; Minecraft needs it
    cores = 2; # Celeron N2840 is dual-core
    diskSize = 8192;
    qemu.options = [ "-vga virtio" ]; # DRM/KMS device for cage
  };

  # Programs Vanja may start. Add an entry here to offer more software.
  vanjaMenu.apps = {
    tic80 = {
      label = "TIC-80";
      command = "${pkgs.lib.getExe pkgs.tic-80} --fullscreen";
    };
    minecraft = {
      label = "Minecraft";
      command = pkgs.lib.getExe pkgs.prismlauncher;
    };
  };

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5; # small eMMC / ESP
  boot.loader.efi.canTouchEfiVariables = true;

  # Hardware
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true; # Wi-Fi / Bluetooth firmware
  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.intel-vaapi-driver ]; # Bay Trail uses the i965 VA-API driver
  };
  services.thermald.enable = true;

  # Little RAM and storage
  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Networking (configure Wi-Fi as admin with `nmtui`)
  networking.hostName = "toshiba";
  networking.networkmanager.enable = true;

  # Sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Power: suspend on lid close; polkit lets the active local user (Vanja's
  # menu) reboot or power off.
  services.logind.settings.Login.HandleLidSwitch = "suspend";
  security.polkit.enable = true;

  # Locale / console
  time.timeZone = "Europe/Skopje"; # TODO: adjust to your time zone
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "us";
    packages = [ pkgs.terminus_font ];
    font = "ter-v20n";
    earlySetup = true;
  };

  # Users
  users.users.admin = {
    isNormalUser = true;
    description = "Admin";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
    ];
    initialPassword = "changeme"; # change with `passwd` after first login
  };

  users.users.vanja = {
    isNormalUser = true;
    description = "Vanja";
    extraGroups = [
      "video"
      "audio"
      "input"
    ];
    # Locked password: Vanja is only reachable through the tty1 auto-login.
    # The login shell is the menu (set in vanja-menu.nix).
    hashedPassword = "!";
  };

  security.sudo.wheelNeedsPassword = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    pciutils
    usbutils
  ];

  # Set to the NixOS release you install with; do not change afterwards.
  system.stateVersion = "26.05";
}
