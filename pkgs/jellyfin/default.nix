{ pkgs }:

pkgs.dockerTools.buildLayeredImage {
  name = pkgs.jellyfin.name;
  tag = pkgs.jellyfin.version;

  config = {
    Cmd = [
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
      "JELLYFIN_CONFIG_DIR=/etc/jellyfin"
      "JELLYFIN_LOG_DIR=/var/log/jellyfin"
      "JELLYFIN_CACHE_DIR=/var/cache/jellyfin"
    ];
    User = "1000:1000";
  };
  contents = [
    pkgs.dockerTools.caCertificates
  ];
}