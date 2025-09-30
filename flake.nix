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
          devenv.shells.default = {
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
              pkgs.gnugrep
              pkgs.gnused
              pkgs.skaffold
              pkgs.skopeo
              pkgs.yq-go
            ];
          };
          packages = {
            syncthing-linux-arm64v8 = pkgs.pkgsCross.aarch64-multiplatform.callPackage ./pkgs/syncthing { };
            jellyfin-linux-arm64v8 = pkgs.pkgsCross.aarch64-multiplatform.callPackage ./pkgs/jellyfin { };
            postgresql-linux-arm64v8 = pkgs.pkgsCross.aarch64-multiplatform.callPackage ./pkgs/postgresql { };
            redis-linux-arm64v8 = pkgs.pkgsCross.aarch64-multiplatform.callPackage ./pkgs/redis { };
            sonarr-linux-arm64v8 = pkgs.pkgsCross.aarch64-multiplatform.callPackage ./pkgs/sonarr { };
            radarr-linux-arm64v8 = pkgs.pkgsCross.aarch64-multiplatform.callPackage ./pkgs/radarr { };
            whisparr-linux-arm64v8 = pkgs.pkgsCross.aarch64-multiplatform.callPackage ./pkgs/whisparr { };
            syncthing-linux-amd64 = pkgs.pkgsCross.gnu64.callPackage ./pkgs/syncthing { };
            jellyfin-linux-amd64 = pkgs.pkgsCross.gnu64.callPackage ./pkgs/jellyfin { };
            postgresql-linux-amd64 = pkgs.pkgsCross.gnu64.callPackage ./pkgs/postgresql { };
            redis-linux-amd64 = pkgs.pkgsCross.gnu64.callPackage ./pkgs/redis { };
            sonarr-linux-amd64 = pkgs.pkgsCross.gnu64.callPackage ./pkgs/sonarr { };
            radarr-linux-amd64 = pkgs.pkgsCross.gnu64.callPackage ./pkgs/radarr { };
            whisparr-linux-amd64 = pkgs.pkgsCross.gnu64.callPackage ./pkgs/whisparr { };
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
