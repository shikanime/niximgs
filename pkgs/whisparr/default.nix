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
    User = "1000:1000";
  };
  contents = [
    pkgs.dockerTools.caCertificates
  ];
}
