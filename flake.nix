{
  description = "Flake stuff";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-22.11-darwin";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, darwin, nixpkgs }: {
    darwinConfigurations =
      let sharedModules = import ./modules; in
      builtins.mapAttrs
        (hostname: deviceModule: darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          modules = sharedModules ++ [ ./common deviceModule ];
        })
       (import ./hosts);
  };
}
