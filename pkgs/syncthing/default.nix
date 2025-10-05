{ pkgs }:

let
  configDir = "/var/lib/syncthing/config";

in
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
      "STCONFDIR=${configDir}"
      "STDATADIR=${dataDir}"
      "STNODEFAULTFOLDER=1"
    ];
    Labels = {
      "org.opencontainers.image.source" = "https://github.com/shikanime/niximgs";
      "org.opencontainers.image.description" = pkgs.syncthing.meta.description;
      "org.opencontainers.image.licenses" = pkgs.syncthing.meta.license.spdxId;
    };
  };
  contents = [
    pkgs.dockerTools.caCertificates
  ];
  extraCommands = ''
    mkdir -p ${configDir} ${dataDir}
  '';
}
