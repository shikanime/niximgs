{ pkgs }:

let
  dataDir = "/var/lib/radarr";
in
pkgs.dockerTools.buildLayeredImage {
  name = "radarr";
  tag = pkgs.radarr.version;

  config = {
    Entrypoint = [
      "${pkgs.radarr}/bin/Radarr"
      "-nobrowser"
      "-data"
      dataDir
    ];
    ExposedPorts = {
      "7878/tcp" = { }; # Web UI
    };
    Labels = {
      "org.opencontainers.image.source" = "https://github.com/shikanime/niximgs";
      "org.opencontainers.image.description" = pkgs.radarr.meta.description;
      "org.opencontainers.image.licenses" = pkgs.radarr.meta.license.spdxId;
    };
  };
  contents = [
    pkgs.dockerTools.caCertificates
  ];
  extraCommands = ''
    mkdir -p ${dataDir}
  '';
}
