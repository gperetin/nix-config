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

  users.users.goran = {
    packages = with pkgs; [
      alacritty
      pkgs-unstable.obsidian
      pkgs-unstable.dbeaver-bin
      rofi
      discord
      polybarFull
      pkgs-unstable.polybar-pulseaudio-control
      xfce.thunar
    ];
  };
}
