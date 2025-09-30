{ pkgs }:

pkgs.dockerTools.buildLayeredImage {
  name = pkgs.syncthing.name;
  tag = pkgs.syncthing.version;

  config = {
    Cmd = [
      "${pkgs.syncthing}/bin/syncthing"
    ];
    ExposedPorts = {
      "8384/tcp" = { }; # Web UI
      "22000/tcp" = { }; # Sync
      "22000/udp" = { }; # Sync
      "21027/udp" = { }; # Discovery broadcasts
    };
  };
  contents = [
    pkgs.dockerTools.caCertificates
  ];
}