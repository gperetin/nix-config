{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
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
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;
  programs.firefox.enable = true;

  programs.ssh = {
    enable = true;
    extraConfig = ''
    Host *
      IdentityAgent ~/.1password/agent.sock
    '';
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  programs.alacritty.enable = true;
  programs.rofi.enable = true;

  services.polybar.enable = true;
  services.polybar.script = "${inputs.dotfiles}/.config/polybar/launch.sh";
  # services.polybar.config = "${inputs.dotfiles}/.config/polybar/config-laptop";

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
