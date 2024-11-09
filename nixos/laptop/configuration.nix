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
    "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
    ./disk-config.nix
    ../../modules/nixos/gui.nix
    ../../modules/nixos/cli.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelParams = [
    # "acpi_backlight=native"

    "amd_pstate=guided"

    "amdgpu"
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
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
    settings.trusted-users = [ "root" "goran" ];
  };

  networking.hostName = "minipc";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Zagreb";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  services = {
    displayManager = {
      defaultSession = "none+i3";
    };
    xserver = {
      enable = true;
      displayManager = {
        lightdm.enable = true;
      };
      videoDrivers = [ "amdgpu "];
      xkb = {
        variant = "";
        layout = "us";
      };
      windowManager.i3 = {
        enable = true;
      };
    };
  };

  # Enable sound with pipewire.
  sound.enable = true;

  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  programs.zsh = {
    enable = true;
  };

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "goran" ];
  };

  users.users = {
    goran = {
      # TODO: You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      # initialPassword = "correcthorsebatterystaple";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = ["wheel" "networkmanager" "audio"];
      shell = pkgs.zsh;
      packages = with pkgs; [
        neovim
        xclip
        polybarFull
        pkgs-unstable.polybar-pulseaudio-control
        devenv
        pkgs-unstable.dbeaver-bin
        vscode-fhs
      ];
    };
  };

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    settings = {
      # Opinionated: forbid root login through SSH.
      PermitRootLogin = "no";
      # Opinionated: use keys only.
      # Remove if you want to SSH using passwords
      PasswordAuthentication = false;
    };
  };

  services.tailscale.enable = true;

  services.syncthing = {
    enable = true;
    user = "goran";
    dataDir = "${config.users.users.goran.home}";
    settings.devices = {
      old-laptop.name = "old-laptop";
      old-laptop.id = "CIPBYY7-YJFRLSY-BRVIYEY-HSIUZZP-RZFSI52-B2TOJSA-GYPP46B-FEXNHAK";
      t14s-gen4.name = "t14s-gen4";
      t14s-gen4.id = "TWH3SXF-YZHLPNO-2RFIALK-RC7HIQD-ZJRV5ZO-J4CTHM4-365NA6S-AKEJLAR";
    };
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
    git
    python3
    alacritty
    brightnessctl
    libinput
    pulseaudio  # for pactl
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
