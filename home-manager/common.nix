{
  inputs,
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:
  {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
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
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  # TODO: Set your username
  home = {
    username = "goran";
    homeDirectory = "/home/goran";
  };

  # Add stuff for your user as you see fit:
  programs.neovim.enable = true;

  home.packages = with pkgs; [
    killall
    gcc
    gnumake # To compile fzf-native for neovim
    pyright
    pkgs-unstable.uv
    pkgs-unstable.ruff
    pkgs-unstable.quarto
    tigervnc
    sqlite
    devenv
    ghostty
  ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;
  programs.firefox.enable = true;
  programs.jujutsu.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    # extraConfig = ''
    # Host *
    #   IdentityAgent ~/.1password/agent.sock
    # '';
  };

  # This requires the secrets repo to be checked out at ~/Code/secrets
  # I used to use `extraConfig` passed to programs.ssh, but the permissions
  # on the symlink there broke Zed editor remote ssh feature
  home.file.".ssh/config".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Code/secrets/sshconfig";

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
  xdg.configFile."starship.toml".source = "${inputs.dotfiles}/.config/starship.toml";

  xdg.configFile."nvim/lua/".source = "${inputs.dotfiles}/.config/nvim/lua/";
  xdg.configFile."nvim/init.lua".source = "${inputs.dotfiles}/.config/nvim/init.lua";

  xdg.configFile."jj/config.toml".source = "${inputs.dotfiles}/.config/jj/config.toml";

  programs.delta.enable = true;
  programs.delta.enableGitIntegration = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  programs.alacritty.enable = true;
  programs.rofi = {
    enable = true;
    modes = [ "combi" ];
    extraConfig.combi-modi = "window,drun,ssh,Sound output:~/bin/rofi_sound.py,:~/bin/rofi_power.sh";
  };

  services.redshift = {
    enable = true;
    temperature.night = 3200;
    longitude = 45.8;
    latitude = 15.99;
  };

  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      i3Support = true;
      alsaSupport = true;
      iwSupport = true;
    };
    # Keep the launcher with the Polybar configurations in the dotfiles repo.
    script = "${inputs.dotfiles}/.config/polybar/launch.sh";
  };

  # i3 invokes this path directly.  Manage it so it cannot drift from the
  # launcher used by the Polybar systemd service.
  xdg.configFile."polybar/launch.sh" = {
    source = "${inputs.dotfiles}/.config/polybar/launch.sh";
    executable = true;
    force = true;
  };

  home.file.".zshrc".source = "${inputs.dotfiles}/.zshrc";
  # xdg.configFile."i3/config".source = "${inputs.dotfiles}/.config/i3/config-laptop";
  # xdg.configFile."alacritty/alacritty.toml".source = "${inputs.dotfiles}/.config/alacritty/alacritty.toml.laptop";
  home.file.".Xmodmap".source = "${inputs.dotfiles}/.Xmodmap";
  # home.file.".xinitrc".source = "${inputs.dotfiles}/.xinitrc";
  home.file.".gitconfig".source = "${inputs.dotfiles}/.gitconfig";
  home.file.".githelpers".source = "${inputs.dotfiles}/.githelpers";
  home.file.".xprofile".text = ''
  xset r rate 220 50
  xset -b
  xmodmap ~/.Xmodmap &
  xcape -e 'Control_L=Escape' &
  xbindkeys
  '';
}
