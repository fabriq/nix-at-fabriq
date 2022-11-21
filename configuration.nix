{ config, pkgs, ... }:

{
  imports = [ ./nix_settings.nix ] ++ import ./modules/module_list.nix;

  environment.systemPackages = [
    pkgs.nil
    pkgs.nixpkgs-fmt
    pkgs.vim
    pkgs.awscli2
    pkgs.python39Full
    pkgs.ripgrep
    pkgs.jq
    pkgs.ffmpeg
    pkgs.imagemagick
    pkgs.htop
    pkgs.curl
    pkgs.inetutils
    pkgs.findutils
    pkgs.coreutils
    pkgs.moreutils
    pkgs.tokei
    pkgs.git
  ];

  deno.enable = true;

  cloudflare_ca.enable = true;

  local_domain.enable = true;
  local_domain.ip_address = "127.0.0.61";
  local_domain.domain = "fabriq.test";
}

