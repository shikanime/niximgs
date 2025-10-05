{ base, pkgs }:

pkgs.dockerTools.buildLayeredImage {
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
      "STGUIADDRESS=0.0.0.0:8384"
      "STNODEFAULTFOLDER=1"
    ];
    Labels = {
      "org.opencontainers.image.source" = "https://github.com/shikanime/niximgs";
      "org.opencontainers.image.description" = pkgs.syncthing.meta.description;
      "org.opencontainers.image.licenses" = pkgs.syncthing.meta.license.spdxId;
    };
    User = "1000:1000";
  };
  fakeRootCommands = ''
    mkdir -p ./var/lib/syncthing/config
    chown 1000:1000 ./var/lib/syncthing/config
    mkdir -p ./var/lib/syncthing/data
    chown 1000:1000 ./var/lib/syncthing/data
  '';
}
