{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.deno;
in

{
  options = {
    deno.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable deno.";
    };

    deno.pkg = mkOption {
      type = types.path;
      default = pkgs.deno;
      defaultText = "pkgs.deno";
      description = "This option specifies the deno package to use.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.pkg ];

    environment.variables = {
      DENO_TLS_CA_STORE = "system";
    };
  };

}
