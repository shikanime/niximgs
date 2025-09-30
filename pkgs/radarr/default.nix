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
    User = "1000:1000";
  };
  contents = [
    pkgs.dockerTools.caCertificates
  ];
}
