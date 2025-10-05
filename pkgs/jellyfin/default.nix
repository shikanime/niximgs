{ base, pkgs }:

pkgs.dockerTools.buildLayeredImage {
  name = "jellyfin";
  tag = pkgs.jellyfin.version;
  fromImage = base;

  config = {
    Entrypoint = [
      "${pkgs.jellyfin}/bin/jellyfin"
    ];
    ExposedPorts = {
      "8096/tcp" = { }; # HTTP Web UI
      "8920/tcp" = { }; # HTTPS Web UI (optional)
      "1900/udp" = { }; # DLNA discovery
      "7359/udp" = { }; # Auto-discovery
    };
    Env = [
      "JELLYFIN_DATA_DIR=/var/lib/jellyfin"
      "JELLYFIN_CACHE_DIR=/var/cache/jellyfin"
    ];
    Labels = {
      "org.opencontainers.image.source" = "https://github.com/shikanime/niximgs";
      "org.opencontainers.image.description" = pkgs.jellyfin.meta.description;
      "org.opencontainers.image.licenses" = pkgs.jellyfin.meta.license.spdxId;
    };
    User = "1000:1000";
  };
  contents = [
    pkgs.dockerTools.fakeNss
  ];
  fakeRootCommands = ''
    mkdir -p ./var/lib/jellyfin
    chown 1000:1000 ./var/lib/jellyfin
    mkdir -p ./var/cache/jellyfin
    chown 1000:1000 ./var/cache/jellyfin
  '';
}
