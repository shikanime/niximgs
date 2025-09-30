{ pkgs }:

pkgs.dockerTools.buildLayeredImage {
  name = "syncthing";
  tag = pkgs.syncthing.version;

  config = {
    Entrypoint = [
      "${pkgs.syncthing}/bin/syncthing"
    ];
    ExposedPorts = {
      "8384/tcp" = { }; # Web UI
      "22000/tcp" = { }; # Sync
      "22000/udp" = { }; # Sync
      "21027/udp" = { }; # Discovery broadcasts
    };
    Env = [
      "STCONFDIR=/var/lib/syncthing/config"
      "STDATADIR=/var/lib/syncthing/data"
      "STNODEFAULTFOLDER=1"
    ];
    User = "1000:1000";
  };
  contents = [
    pkgs.dockerTools.caCertificates
  ];
}
