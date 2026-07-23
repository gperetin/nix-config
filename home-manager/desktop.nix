{
  inputs,
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}: let
  gdkScale1 = name: executable:
    pkgs.writeShellScriptBin name ''
      export GDK_SCALE=1
      exec ${executable} "$@"
    '';

  discordScale1 = gdkScale1 "discord-scale-1" "${pkgs.discord}/bin/Discord";
  obsidianScale1 = gdkScale1 "obsidian-scale-1" "${pkgs-unstable.obsidian}/bin/obsidian";
  onePasswordScale1 = gdkScale1 "1password-scale-1" "${pkgs._1password-gui}/bin/1password";
  ghosttyScale1 = gdkScale1 "ghostty-scale-1" "${pkgs.ghostty}/bin/ghostty";
  firefoxOpenUrl = pkgs.writeShellScriptBin "firefox-open-url" ''
    # Ghostty runs at GDK scale 1, but Firefox belongs on the HiDPI display.
    export GDK_SCALE=2
    export GDK_DPI_SCALE=0.5
    # Firefox currently runs the default profile in the XDG location. Specify
    # it explicitly so this invocation is remote-controlled by that instance.
    profile_root="''${XDG_CONFIG_HOME:-$HOME/.config}/.mozilla/firefox"
    profile_path="$(awk -F= '$1 == "Path" { path = $2 } $1 == "Default" && $2 == "1" { print path; exit }' "$profile_root/profiles.ini")"

    if [ -n "$profile_path" ]; then
      exec ${pkgs.firefox}/bin/firefox --profile "$profile_root/$profile_path" --new-tab "$@"
    fi

    exec ${pkgs.firefox}/bin/firefox --new-tab "$@"
  '';
in {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    ./common.nix
  ];

  services.polybar.config = "${inputs.dotfiles}/.config/polybar/config-desktop";
  systemd.user.services.polybar = {
    # This is here so that the PATH is passed to the Polybar script
    Service.Environment = lib.mkForce "";
    Service.PassEnvironment = "PATH";
  };

  home.packages = [
    discordScale1
    obsidianScale1
    onePasswordScale1
    ghosttyScale1
  ];

  xdg.configFile = {
    "i3/config".source = "${inputs.dotfiles}/.config/i3/config-desktop";
    "alacritty/alacritty.toml".source = "${inputs.dotfiles}/.config/alacritty/alacritty.toml.desktop";
    "ghostty/config".source = "${inputs.dotfiles}/.config/ghostty/config-desktop";
  };

  # Override the system desktop entries so GUI launchers use a normal GTK scale.
  xdg.desktopEntries = {
    # Ghostty opens Ctrl-clicked URLs through the default browser's desktop
    # entry. Force Firefox's HiDPI environment and ask its running instance
    # to add the URL as a tab rather than create a separately scaled window.
    firefox = {
      name = "Firefox";
      exec = "${firefoxOpenUrl}/bin/firefox-open-url %U";
      icon = "firefox";
      categories = [ "Network" "WebBrowser" ];
      mimeType = [ "text/html" "text/xml" "application/xhtml+xml" "x-scheme-handler/http" "x-scheme-handler/https" ];
    };
    discord = {
      name = "Discord";
      exec = "${discordScale1}/bin/discord-scale-1 %U";
      icon = "discord";
      categories = [ "Network" "InstantMessaging" ];
    };
    obsidian = {
      name = "Obsidian";
      exec = "${obsidianScale1}/bin/obsidian-scale-1 %U";
      icon = "obsidian";
      categories = [ "Office" ];
    };
    "1password" = {
      name = "1Password";
      exec = "${onePasswordScale1}/bin/1password-scale-1 %U";
      icon = "1password";
      categories = [ "Utility" "Security" ];
    };
    "com.mitchellh.ghostty" = {
      name = "Ghostty";
      exec = "${ghosttyScale1}/bin/ghostty-scale-1 --gtk-single-instance=true";
      icon = "com.mitchellh.ghostty";
      categories = [ "System" "TerminalEmulator" ];
    };
  };

  # HiDPI font rendering for PA32QCV 6K (219 DPI native, 2x logical scale)
  xresources.properties = {
    "Xft.dpi"       = 220;
    "Xft.antialias" = true;
    "Xft.hinting"   = true;
    "Xft.hintstyle" = "hintslight";
    "Xft.lcdfilter" = "lcddefault";
    "Xft.rgba"      = "rgb";
    "Xcursor.size"  = 48;
  };

  home.file.".xprofile".text = ''
  # HiDPI scaling for Asus PA32QCV 6K
  # GDK_SCALE=2 tells GTK to scale UI 2x; GDK_DPI_SCALE=0.5 prevents double-scaling fonts
  export GDK_SCALE=2
  export GDK_DPI_SCALE=0.5
  export QT_AUTO_SCREEN_SCALE_FACTOR=1
  export QT_SCALE_FACTOR=2
  export XCURSOR_SIZE=48

  xset r rate 220 50
  xset -b
  xmodmap ~/.Xmodmap &
  xcape -e 'Control_L=Escape' &
  xbindkeys

  # Switch back to triple_nvidia_drivers.sh when using 3-monitor setup
  source ~/.screenlayout/pa32qcv_6k.sh
  '';

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersio
  home.stateVersion = "23.05";
}
