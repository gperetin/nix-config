set shell := ["bash", "-euo", "pipefail", "-c"]

user := env_var("USER")
# Flake output names do not necessarily match networking.hostName (for example,
# the `desktop` output configures the host named `nixos`).
flake_host := `HOSTNAME="$(hostname)" nix eval --impure --raw --expr 'let flake = builtins.getFlake (toString ./.); hostName = builtins.getEnv "HOSTNAME"; matches = builtins.filter (name: flake.nixosConfigurations.${name}.config.networking.hostName == hostName) (builtins.attrNames flake.nixosConfigurations); in if builtins.length matches == 1 then builtins.head matches else throw "expected exactly one NixOS configuration for host ${hostName}"'`

# Rebuild and activate NixOS for this machine.
nixos:
    sudo nixos-rebuild switch --flake .#{{flake_host}}

# Rebuild and activate Home Manager for this machine.
home:
    home-manager switch --flake .#{{user}}@{{flake_host}}

# Update the dotfiles input, then rebuild and activate Home Manager.
dotfiles:
    nix flake lock --update-input dotfiles
    home-manager switch --flake .#{{user}}@{{flake_host}}
