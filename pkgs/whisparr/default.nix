{ pkgs }:

pkgs.dockerTools.buildLayeredImage {
  name = "whisparr";
  tag = pkgs.whisparr.version;

  config = {
    Entrypoint = [
      "${pkgs.whisparr}/bin/Whisparr"
      "-nobrowser"
      "-data"
      "/var/lib/whisparr"
    ];
    ExposedPorts = {
      "6969/tcp" = { }; # Web UI
    };
    Labels = {
      "org.opencontainers.image.source" = "https://github.com/shikanime/niximgs";
      "org.opencontainers.image.description" = pkgs.whisparr.meta.description;
      "org.opencontainers.image.licenses" = pkgs.whisparr.meta.license.spdxId;
    };
  };
  contents = [
    pkgs.dockerTools.caCertificates
  ];
}
