{
  inputs = {
    devenv.url = "github:cachix/devenv";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  nixConfig = {
    extra-public-keys = [
      "shikanime.cachix.org-1:OrpjVTH6RzYf2R97IqcTWdLRejF6+XbpFNNZJxKG8Ts="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
    extra-substituters = [
      "https://shikanime.cachix.org"
      "https://devenv.cachix.org"
    ];
  };

  outputs =
    inputs@{
      devenv,
      flake-parts,
      treefmt-nix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        devenv.flakeModule
        treefmt-nix.flakeModule
      ];
      perSystem =
        { self', pkgs, ... }:
        {
          treefmt = {
            projectRootFile = "flake.nix";
            enableDefaultExcludes = true;
            programs = {
              hclfmt.enable = true;
              nixfmt.enable = true;
              prettier.enable = true;
              shfmt.enable = true;
              statix.enable = true;
              terraform.enable = true;
            };
            settings.global.excludes = [
              "*.excalidraw"
              "*.terraform.lock.hcl"
              ".gitattributes"
              "LICENSE"
            ];
          };
          devenv.shells = {
            default = {
              containers = pkgs.lib.mkForce { };
              languages.nix.enable = true;
              cachix = {
                enable = true;
                push = "shikanime";
              };
              git-hooks.hooks = {
                actionlint.enable = true;
                deadnix.enable = true;
                flake-checker.enable = true;
                shellcheck.enable = true;
              };
              packages = [
                pkgs.gh
                pkgs.gitnr
                pkgs.nushell
                pkgs.sapling
                pkgs.skaffold
              ];
            };
            build = {
              containers = pkgs.lib.mkForce { };
              packages = [
                pkgs.nushell
                pkgs.skaffold
              ];
            };
          };
          packages = {
            base = pkgs.callPackage ./pkgs/base { };
            jellyfin = pkgs.callPackage ./pkgs/jellyfin { inherit (self'.packages) base; };
            mlflow = pkgs.callPackage ./pkgs/mlflow { inherit (self'.packages) base; };
            postgresql = pkgs.callPackage ./pkgs/postgresql { inherit (self'.packages) base; };
            radarr = pkgs.callPackage ./pkgs/radarr { inherit (self'.packages) base; };
            redis = pkgs.callPackage ./pkgs/redis { inherit (self'.packages) base; };
            sonarr = pkgs.callPackage ./pkgs/sonarr { inherit (self'.packages) base; };
            syncthing = pkgs.callPackage ./pkgs/syncthing { inherit (self'.packages) base; };
            vaultwarden = pkgs.callPackage ./pkgs/vaultwarden { inherit (self'.packages) base; };
            whisparr = pkgs.callPackage ./pkgs/whisparr { inherit (self'.packages) base; };
          };
        };
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    };
}
