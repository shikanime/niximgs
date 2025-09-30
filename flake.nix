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
              pkgs.nushell
              pkgs.skaffold
            ];
          };
          packages = {
            jellyfin = pkgs.callPackage ./pkgs/jellyfin { };
            postgresql = pkgs.callPackage ./pkgs/postgresql { };
            radarr = pkgs.callPackage ./pkgs/radarr { };
            redis = pkgs.callPackage ./pkgs/redis { };
            sonarr = pkgs.callPackage ./pkgs/sonarr { };
            syncthing = pkgs.callPackage ./pkgs/syncthing { };
            uv = pkgs.callPackage ./pkgs/uv { };
            vaultwarden = pkgs.callPackage ./pkgs/vaultwarden { };
            whisparr = pkgs.callPackage ./pkgs/whisparr { };
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
