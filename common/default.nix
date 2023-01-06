# This Nix expression is the common device configuration loaded for all devices.

{ config, pkgs, ... }:

{
  imports = [ ./nix_settings.nix ./system_packages.nix ];

  cloudflare_ca.enable = true;

  local_domain.enable = true;
  local_domain.ip_address = "127.0.0.61";
  local_domain.domain = "fabriq.test";
}

