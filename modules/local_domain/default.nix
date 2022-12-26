{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.local_domain;
in

{
  options = {
    local_domain.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable the local domain.";
    };

    local_domain.dnsmasq = mkOption {
      type = types.path;
      default = pkgs.dnsmasq;
      defaultText = "pkgs.dnsmasq";
      description = "This option specifies the dnsmasq package to use.";
    };

    local_domain.nginx = mkOption {
      type = types.path;
      default = pkgs.nginxStable;
      defaultText = "pkgs.nginxStable";
      description = "This option specifies the nginx package to use.";
    };

    local_domain.cacert = mkOption {
      type = types.path;
      default = pkgs.cacert;
      defaultText = "pkgs.cacert";
      description = "This option specifies the cacert package to install; it is here to prevent an unregistered scheme error.";
    };

    local_domain.ip_address = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "This option specifies the IP address to set as a loopback alias, and on which dnsmasq and nginx will bind.";
    };

    local_domain.gateway_url = mkOption {
      type = types.str;
      default = "http://localhost:61000";
      description = "The URL to the Gateway service.";
    };

    # TODO: The provided certificate only works with fabriq.test.
    # The module should include certificate generation.
    local_domain.domain = mkOption {
      type = types.str;
      default = "local.test";
      description = "The local domain that should be setup.";
    };

    local_domain.logs_directory = mkOption {
      type = types.str;
      default = "/var/log/local_domain";
      description = "The directory in which to store logs";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.dnsmasq cfg.nginx ];

    launchd.daemons.dnsmasq = {
      path = [ cfg.dnsmasq ];
      serviceConfig = {
        Program = "${cfg.dnsmasq}/bin/dnsmasq";
        ProgramArguments = [
          "dnsmasq"
          "--listen-address=${cfg.ip_address}"
          "--port=53"
          "--address=/fabriq.test/${cfg.ip_address}"
          "--keep-in-foreground"
        ];

        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "${cfg.logs_directory}/dnsmasq.log";
        StandardErrorPath = "${cfg.logs_directory}/dnsmasq_error.log";
      };
    };

    environment.etc."resolver/fabriq.test" = {
      enable = true;
      text = ''
        port 53
        nameserver ${cfg.ip_address}
      '';
    };

    launchd.daemons.nginx =
      let
        nginxConfig = ''
          worker_processes  1;

          events {
              worker_connections  1024;
          }

          http {
              include       ${cfg.nginx}/conf/mime.types;
              default_type  application/octet-stream;
              sendfile        on;
              keepalive_timeout  65;
              server {
                 listen       ${cfg.ip_address}:443 ssl;
                 server_name  *.${cfg.domain};

                 ssl_certificate      ${./cert/fabriq.test.crt};
                 ssl_certificate_key  ${./cert/fabriq.test.key};

                 ssl_session_cache    shared:SSL:1m;
                 ssl_session_timeout  5m;

                 ssl_ciphers  HIGH:!aNULL:!MD5;
                 ssl_prefer_server_ciphers  on;

                 location / {
                    proxy_set_header Host $host;
                    proxy_pass ${cfg.gateway_url};
                 }
              }
          }
        '';
      in
      {
        path = [ cfg.nginx ];
        serviceConfig = {
          Program = "${cfg.nginx}/bin/nginx";
          ProgramArguments = [
            "nginx"
            "-c"
            "${pkgs.writeText "nginx.conf" nginxConfig}"
            "-p"
            "${pkgs.nginx}/empty"
            "-g"
            "daemon off;"
          ];
          KeepAlive = true;
          RunAtLoad = true;
          WorkingDirectory = "${pkgs.nginx}/conf";
          StandardOutPath = "${cfg.logs_directory}/nginx.log";
          StandardErrorPath = "${cfg.logs_directory}/nginx_error.log";
        };
      };

    launchd.daemons.aliasForIpPortForwarder = mkIf (cfg.ip_address != "127.0.0.1") {
      serviceConfig = {
        ProgramArguments = [ "/sbin/ifconfig" "lo0" "alias" cfg.ip_address ];
        RunAtLoad = true;
        Nice = 10;
        KeepAlive = false;
        AbandonProcessGroup = true;
        StandardOutPath = "${cfg.logs_directory}/alias_for_ip_forwarder.log";
        StandardErrorPath = "${cfg.logs_directory}/alias_for_ip_forwarder_error.log";
      };
    };
  };
}
