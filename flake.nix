{
  inputs = {
    devenv.url = "github:cachix/devenv";
    devlib.url = "github:shikanime-studio/devlib";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks.url = "github:cachix/git-hooks.nix";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  nixConfig = {
    extra-substituters = [
      "https://cachix.cachix.org"
      "https://devenv.cachix.org"
      "https://shikanime.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "shikanime.cachix.org-1:OrpjVTH6RzYf2R97IqcTWdLRejF6+XbpFNNZJxKG8Ts="
    ];
  };

  outputs =
    inputs@{
      devenv,
      devlib,
      flake-parts,
      git-hooks,
      treefmt-nix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        devenv.flakeModule
        devlib.flakeModule
        git-hooks.flakeModule
        treefmt-nix.flakeModule
      ];
      perSystem =
        { self', pkgs, ... }:
        {
          devenv.shells = {
            default = {
              imports = [
                devlib.devenvModules.shikanime-studio
              ];
              packages = [
                pkgs.buildah
                pkgs.gh
                pkgs.nushell
                pkgs.sapling
                pkgs.skaffold
                pkgs.skopeo
              ];
              treefmt.enable = true;
            };
            build = {
              containers = pkgs.lib.mkForce { };
              packages = [
                pkgs.buildah
                pkgs.nushell
                pkgs.skaffold
                pkgs.skopeo
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
