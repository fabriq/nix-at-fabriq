{ config, pkgs, ... }:

{
  imports = [ ./nix_settings.nix ] ++ import ./modules/module_list.nix;

  # List of packages installed in system profile.
  environment.systemPackages = [ pkgs.nil pkgs.nixpkgs-fmt pkgs.vim ];

  deno.enable = true;

  cloudflare_ca.enable = true;

  local_domain.enable = true;
  local_domain.ip_address = "127.0.0.61";
  local_domain.domain = "fabriq.test";
}

