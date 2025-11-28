# NixOS configuration

This flake was originally forked from Misterio77's minimal [starter configuration](https://github.com/Misterio77/nix-starter-configs) and adopted for multiple hosts.

## Installing on a fresh box

This is the process I go through when doing a fresh install of NixOS using this config.

1. Download the NixOS ISO (graphical installer) and boot it from USB
    - Graphical installer just because it's simpler to set up WIFI, we won't actually install anything using the installer. Also, helps to have a browser
2. Connect to the Internet and clone this repo
    - HTTPS is fine for cloning, we won't be adding anything to it here
3. Partition the drive using [Disko](https://github.com/nix-community/disko/blob/master/docs/quickstart.md)

   `sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko <path-to-disk-config.nix>`
4. Generate NixOS config

    `nixos-generate-config --no-filesystems --root /mnt`
5. Use the newly generated `hardware-configuration.nix` if there isn't one in the repo for the host we're provisioning.
6. Make sure the `secrets` repo is checked out at `~/Code/secrets`
    - Probably easiest to just download as zip and unpack
7. Install from flake
    ```
    sudo nixos-install --flake .#hostname --impure
    ```
8. Copy the `secrets` and `nix-config` folders into `/mnt/home/goran/Code`
9. Reboot
10. Connect to wifi using `nmtui`
11. Set up home-manager
    ```
    home-manager switch --flake .#username@hostname
    ```
12. Reboot


## Updating the config

Host config: `sudo nixos-rebuild switch --flake .#desktop` (replace "desktop" with the hostname)

Home manager: `home-manager switch --flake .#goran@desktop`


## Updating

To force the flake to fetch updates for a single input (I use this for dotfiles repo):

    nix flake lock --update-input dotfiles

To update all the package definitions:

    nix flake update
