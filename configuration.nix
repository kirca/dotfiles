# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      <nixos-hardware/asus/zephyrus/ga401>
      ./hardware-configuration.nix
    ];

  boot.kernelPackages = pkgs.linuxPackages_6_1;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "lambda-is"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # There is issue that docker network interfaces keep getting renamed, example logs:
  # eth0: renamed from veth3a0ecb2
  # docker_gwbridge: port 2(veth85ecf6b) entered disabled state
  # br0: port 3(veth84) entered blocking state
  # br0: port 3(veth84) entered forwarding state
  # eth1: renamed from veth0933893
  # IPv6: ADDRCONF(NETDEV_CHANGE): veth85ecf6b: link becomes ready
  # ...
  # this creates network connectivity issues, wifi dropping.
  # It looks like they are renamed by the system and docker restores the name.
  # This should be connected with:
  # https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/#:~:text=Starting%20with%20v197%20systemd%2Fudev,but%20should%20fix%20real%20problems.
  # But disabling this doesn't seem to change anything.
  # Only solution for now is to bring down containers so that veth* network interfaces are closed.
  networking.usePredictableInterfaceNames = false;

  networking.extraHosts =
    ''
    127.0.0.1	arseno.docker ekyrail.docker eplatform.docker dosejuice.docker eboucher.docker d-rl.docker aerovac.docker pk-sound.docker leika.docker amh.docker balcon-ideal.docker createch.docker tohu.docker laberge.docker niche10.docker archeti15.docker thorasys.docker renover-habitat.docker artisans-indiens.docker corcoran.docker caf-caf.docker pk-hq.docker
    '';

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Skopje";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "mk_MK.utf8";
    LC_IDENTIFICATION = "mk_MK.utf8";
    LC_MEASUREMENT = "mk_MK.utf8";
    LC_MONETARY = "mk_MK.utf8";
    LC_NAME = "mk_MK.utf8";
    LC_NUMERIC = "mk_MK.utf8";
    LC_PAPER = "mk_MK.utf8";
    LC_TELEPHONE = "mk_MK.utf8";
    LC_TIME = "mk_MK.utf8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable postgres
  services.postgresql.enable = true;
  services.postgresql.package = pkgs.postgresql_11;
  services.postgresql.authentication = ''local all all              trust'';

  # Docker
  virtualisation.docker = {
    enable = true;
    liveRestore = false;  # incompatible with docker swarm
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us,mk";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];
  services.avahi.enable = true;
  # Important to resolve .local domains of printers, otherwise you get an error
  # like  "Impossible to connect to XXX.local: Name or service not known"
  services.avahi.nssmdns = true;

  # Enable scanner support
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.hplipWithPlugin ];
  nixpkgs.config.packageOverrides = pkgs: {
    xsaneGimp = pkgs.xsane.override { gimpSupport = true; };
  };

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kiril = {
    isNormalUser = true;
    description = "Kiril";
    extraGroups = [ "networkmanager" "wheel" "docker" "scanner" "lp" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    emacs
    firefox
    google-chrome
    terminator
    git
    thunderbird
    ntfs3g
    exfat
    texlive.combined.scheme-full
    zoom-us
    libreoffice
    spotify
    pinta
    libpulseaudio
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.steam.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
