{ pkgs }:

pkgs.dockerTools.buildLayeredImage {
  name = "sonarr";
  tag = pkgs.sonarr.version;

  config = {
    Entrypoint = [
      "${pkgs.sonarr}/bin/Sonarr"
      "-nobrowser"
      "-data"
      "/var/lib/sonarr"
    ];
    ExposedPorts = {
      "8989/tcp" = { }; # Web UI
    };
    User = "1000:1000";
  };
  contents = [
    pkgs.dockerTools.caCertificates
  ];
}
