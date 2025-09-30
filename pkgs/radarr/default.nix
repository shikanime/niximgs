{ pkgs }:

pkgs.dockerTools.buildLayeredImage {
  name = "radarr";
  tag = pkgs.radarr.version;

  config = {
    Entrypoint = [
      "${pkgs.radarr}/bin/Radarr"
      "-nobrowser"
      "-data"
      "/var/lib/radarr"
    ];
    ExposedPorts = {
      "7878/tcp" = { }; # Web UI
    };
    Labels = {
      "org.opencontainers.image.source" = "https://github.com/shikanime/niximgs";
      "org.opencontainers.image.description" = pkgs.radarr.meta.description;
      "org.opencontainers.image.licenses" = pkgs.radarr.meta.license.spdxId;
    };
    User = "1000:1000";
  };
  contents = [
    pkgs.dockerTools.caCertificates
  ];
}
