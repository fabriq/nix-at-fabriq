sudo scutil --set HostName fabriq-mohamed-lt
nix build '.#darwinConfigurations.fabriq-mohamed-lt.system' --extra-experimental-features "nix-command flakes"
