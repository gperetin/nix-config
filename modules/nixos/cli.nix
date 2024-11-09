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
      vim
      wget
      btop
      ripgrep
      fzf
      direnv
      xcape
      xorg.xmodmap
      xclip
      scrot
      lsd
      bat
      fd
      jq
    ];
  };
}
