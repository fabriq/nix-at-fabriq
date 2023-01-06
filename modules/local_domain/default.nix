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
      default = "/var/log/local-domain";
      description = "The directory in which to store logs";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.dnsmasq cfg.nginx ];

    security.pki.certificateFiles = [ ./cert/fabriq.test.crt ];

    launchd.daemons."local-domain.alias" = mkIf (cfg.ip_address != "127.0.0.1") {
      serviceConfig = {
        ProgramArguments = [ "/sbin/ifconfig" "lo0" "alias" cfg.ip_address ];
        RunAtLoad = true;
        Nice = 10;
        KeepAlive = false;
        AbandonProcessGroup = true;
        StandardOutPath = "${cfg.logs_directory}/daemons/alias/stdout.log";
        StandardErrorPath = "${cfg.logs_directory}/daemons/alias/stderr.log";
      };
    };

    launchd.daemons."local-domain.dnsmasq" = {
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


        KeepAlive = {
          OtherJobEnabled = mkIf (cfg.ip_address != "127.0.0.1") {
            "org.nixos.local-domain.alias" = true;
          };
        };
        RunAtLoad = true;
        StandardOutPath = "${cfg.logs_directory}/daemons/dnsmasq/stdout.log";
        StandardErrorPath = "${cfg.logs_directory}/daemons/dnsmasq/stderr.log";
      };
    };

    environment.etc."resolver/fabriq.test" = {
      enable = true;
      text = ''
        port 53
        nameserver ${cfg.ip_address}
      '';
    };

    launchd.daemons."local-domain.nginx" =
      let
        # By default, nginx will write its logs in /var/log/nginx.
        # We don't want this instance of nginx to conflict with another,
        # so we are overwriting it.
        nginxLogDirectory = "${cfg.logs_directory}/nginx";
        accessLogFile = "${nginxLogDirectory}/access.log";
        errorLogFile = "${nginxLogDirectory}/error.log";
        pidFile = "${nginxLogDirectory}/nginx.pid";
        nginxTmpDirectory = "/tmp/local-domain/nginx";
        clientBodyTempPath = "${nginxTmpDirectory}/client_body";
        proxyCachePath = "${nginxTmpDirectory}/proxy_cache";
        proxyTempPath = "${nginxTmpDirectory}/proxy_temp";

        nginxConfig = ''
          pid               ${pidFile};
          worker_processes  1;

          events {
              worker_connections  1024;
          }

          http {
              include               ${cfg.nginx}/conf/mime.types;
              default_type          application/octet-stream;
              sendfile              on;
              keepalive_timeout     65;

              access_log            ${accessLogFile};
              error_log             ${errorLogFile};

              client_body_temp_path ${nginxTmpDirectory}/client_body;
              proxy_temp_path       ${nginxTmpDirectory}/proxy;
              fastcgi_temp_path     ${nginxTmpDirectory}/fastcgi;
              uwsgi_temp_path       ${nginxTmpDirectory}/uwsgi;
              scgi_temp_path        ${nginxTmpDirectory}/scgi;

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
        script = ''
          set -e
          ${pkgs.coreutils}/bin/mkdir -p ${nginxLogDirectory} ${nginxTmpDirectory}
          ${pkgs.coreutils}/bin/touch ${pidFile} ${accessLogFile} ${errorLogFile}
          exec ${cfg.nginx}/bin/nginx -c ${pkgs.writeText "nginx.conf" nginxConfig} -e ${errorLogFile} -p ${pkgs.nginx}/empty -g 'daemon off;'
        '';
        serviceConfig = {
          KeepAlive = {
            OtherJobEnabled = {
              "org.nixos.local-domain.dnsmasq" = true;
            };
          };
          RunAtLoad = true;
          WorkingDirectory = "${pkgs.nginx}/conf";
          StandardOutPath = "${cfg.logs_directory}/daemons/nginx/stdout.log";
          StandardErrorPath = "${cfg.logs_directory}/daemons/nginx/stderr.log";
        };
      };
  };
}
