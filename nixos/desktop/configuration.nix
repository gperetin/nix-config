# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # packageOverrides = pkgs: {
      #   unstable = import nixpkgs-unstable {
      #     config = config.nixpkgs.config;
      #   };
      # };
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."luks-777a43ef-e518-4737-aaef-d648e58c7c14".device = "/dev/disk/by-uuid/777a43ef-e518-4737-aaef-d648e58c7c14";

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  services.tailscale.enable = true;

  # Users
  users.users.goran = {
    isNormalUser = true;
    description = "Goran";
    extraGroups = [ "networkmanager" "wheel" "audio" "libvirtd" "plugdev"];
    shell = pkgs.zsh;
    packages = with pkgs; [
      firefox
      neovim
      discord
      redshift
      rofi
      polybarFull
      pkgs-unstable.polybar-pulseaudio-control # For volume controls in Polybar
      virt-manager
      zoom-us
      pkgs-unstable.obsidian
      tigervnc
      nodePackages.pyright
      xclip
      pkgs-unstable.dbeaver-bin
      vscode-fhs
      sqlite
      vc
      devenv
      jq
      bat
    ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Zagreb";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Hardware config
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # UI config
  services = {
    displayManager = {
      defaultSession = "none+i3";
    };
    xserver = {
      enable = true;
      displayManager = {
        lightdm.enable = true;
      };
      deviceSection = ''
        Option "Coolbits" "26"
      '';
      videoDrivers = ["nvidia"];
      windowManager.i3.enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };
  };

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Virtualization
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };
  programs.virt-manager.enable = true;

  # ZSA keyboard
  hardware.keyboard.zsa.enable = true;
  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"
  '';
  services.udev.packages = [ pkgs.via ];

  # Steam
  programs.steam.enable = true;

  # Shell
  programs.starship = {
    enable = true;
    settings = {
      command_timeout = 2000;
    };
  };
  programs.zsh.enable = true;

  # Password manager
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "goran" ];
  };
  programs._1password.enable = true;

  services.syncthing = {
    enable = true;
    user = "goran";
    dataDir = "${config.users.users.goran.home}";
  };

  programs.fzf = {
    keybindings = true;
    fuzzyCompletion = true;
  };

  fonts.packages = with pkgs; [
    font-awesome
    material-icons
    noto-fonts
    (nerdfonts.override { fonts = [ "Hack" "FiraCode" "JetBrainsMono" "Noto" ]; })
  ];

  environment.systemPackages = with pkgs; [
   zsh
   vim
   wget
   btop
   python3
   ripgrep
   fzf
   alacritty
   git
   starship
   arandr
   direnv
   pulseaudio-ctl
   xcape
   xorg.xmodmap
   lm_sensors
   spice
   spice-gtk
   spice-protocol
   virt-viewer
   pulseaudio
   vdpauinfo
   scrot
   killall
   gnumake
   gcc
   unzip
   zlib
   lsd
   cloc
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
