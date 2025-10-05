{ base, pkgs }:

pkgs.dockerTools.streamLayeredImage {
  name = "syncthing";
  tag = pkgs.syncthing.version;
  fromImage = base;

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
    Labels = {
      "org.opencontainers.image.description" = pkgs.syncthing.meta.description;
      "org.opencontainers.image.licenses" = pkgs.syncthing.meta.license.spdxId;
    };
  };
  extraCommands = ''
    mkdir -p var/lib/syncthing/config var/lib/syncthing/data
  '';
}
