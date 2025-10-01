{ pkgs }:

pkgs.dockerTools.buildLayeredImage {
  name = "sonarr";
  tag = pkgs.sonarr.version;

  config = {
    Entrypoint = [
      "${pkgs.sonarr}/bin/Sonarr"
    ];
    Cmd = [
      "-nobrowser"
      "-data"
      "/var/lib/sonarr"
    ];
    ExposedPorts = {
      "8989/tcp" = { }; # Web UI
    };
    Labels = {
      "org.opencontainers.image.source" = "https://github.com/shikanime/niximgs";
      "org.opencontainers.image.description" = pkgs.sonarr.meta.description;
      "org.opencontainers.image.licenses" = pkgs.sonarr.meta.license.spdxId;
    };
  };
  contents = [
    pkgs.dockerTools.caCertificates
  ];
}
