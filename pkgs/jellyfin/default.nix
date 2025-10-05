{ pkgs }:

let
  dataDir = "/var/lib/jellyfin";
  configDir = "/var/lib/jellyfin/config";
  cacheDir = "/var/cache/jellyfin";
  logDir = "/var/lib/jellyfin/log";
in
pkgs.dockerTools.buildLayeredImage {
  name = "jellyfin";
  tag = pkgs.jellyfin.version;

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
      "JELLYFIN_DATA_DIR=${dataDir}"
      "JELLYFIN_CONFIG_DIR=${configDir}"
      "JELLYFIN_LOG_DIR=${logDir}"
      "JELLYFIN_CACHE_DIR=${cacheDir}"
    ];
    Labels = {
      "org.opencontainers.image.source" = "https://github.com/shikanime/niximgs";
      "org.opencontainers.image.description" = pkgs.jellyfin.meta.description;
      "org.opencontainers.image.licenses" = pkgs.jellyfin.meta.license.spdxId;
    };
  };
  contents = [
    pkgs.dockerTools.caCertificates
  ];
  extraCommands = ''
    mkdir -p /tmp ${dataDir} ${configDir} ${logDir} ${cacheDir}
  '';
}
