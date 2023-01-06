# This Nix expression is the common device configuration loaded for all devices.

{ config, pkgs, ... }:

{
  deno.enable = true;

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
    pkgs.gnused
    pkgs.tokei
    pkgs.git
  ];
}

