{ config, pkgs, ... }:

{
  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.nixpkgs/darwin-configuration.nix
  environment.darwinConfig = "$HOME/.nixpkgs/darwin-configuration.nix";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Changing the nix settings so that they match flox.
  nix.settings = {
    auto-optimise-store = true;
    sandbox = true;
    sandbox-fallback = false;
    extra-sandbox-paths = [ "/System/Library/LaunchDaemons/com.apple.oahd.plist" ];
    substituters = [ "https://cache.nixos.org/" ];
    trusted-substituters = [ "https://cache.floxdev.com?trusted=1" ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "flox-store-public-0:8c/B+kjIaQ+BloCmNkRUKwaVPFWkriSAd0JJvuDu4F0="
    ];
    trusted-users = [ "root" "nix" "@wheel" ];
    system-features = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    experimental-features = [ "nix-command" "flakes" ];
    keep-outputs = true;
    keep-derivations = true;
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;
}
