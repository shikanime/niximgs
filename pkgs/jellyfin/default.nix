{ pkgs }:

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
      "JELLYFIN_DATA_DIR=/var/lib/jellyfin/data"
      "JELLYFIN_CONFIG_DIR=/var/lib/jellyfin/config"
      "JELLYFIN_LOG_DIR=/var/log/jellyfin"
      "JELLYFIN_CACHE_DIR=/var/cache/jellyfin"
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
    mkdir -m 0777 /tmp
    mkdir \
      /var/lib/jellyfin/data \
      /var/lib/jellyfin/config \
      /var/log/jellyfin \
      /var/cache/jellyfin
  '';
}
