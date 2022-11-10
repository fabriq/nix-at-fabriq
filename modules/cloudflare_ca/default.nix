{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.deno;
in

{
  options = {
    cloudflare_ca.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to add Cloudflare's certificate to the bundle nix relies on.";
    };
  };

  config = mkIf cfg.enable {
    security.pki.certificateFiles = [ ./cloudflare.crt ];
  };
}
