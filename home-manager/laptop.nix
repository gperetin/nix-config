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
    ./common.nix
  ];

  services.polybar.config = "${inputs.dotfiles}/.config/polybar/config-t14s-gen4";

  systemd.user.services.polybar = {
    # This is here so that the PATH is passed to the Polybar script
    Service.Environment = lib.mkForce "";
    Service.PassEnvironment = "PATH";
  };

  xdg.configFile = {
    "i3/config".source = "${inputs.dotfiles}/.config/i3/config-laptop";
    "alacritty/alacritty.toml".source = "${inputs.dotfiles}/.config/alacritty/alacritty.toml.laptop";
  };

  home.file.".xprofile".text = ''
  xset r rate 220 50
  xset -b
  xmodmap ~/.Xmodmap &
  xcape -e 'Control_L=Escape' &
  xbindkeys
  '';

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersio
  home.stateVersion = "23.05";
}
