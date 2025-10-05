{ base, pkgs }:

pkgs.dockerTools.buildLayeredImage {
  name = "radarr";
  tag = pkgs.radarr.version;
  fromImage = base;

  config = {
    Cmd = [
      "-nobrowser"
      "-data"
      "/var/lib/radarr/data"
    ];
    Entrypoint = [
      "${pkgs.radarr}/bin/Radarr"
    ];
    Env = [
      "PATH=${pkgs.radarr}/bin"
      "XDG_CONFIG_HOME=/var/lib/radarr/config"
    ];
    ExposedPorts = {
      "7878/tcp" = { }; # Web UI
    };
    Labels = {
      "org.opencontainers.image.source" = "https://github.com/shikanime/niximgs";
      "org.opencontainers.image.description" = pkgs.radarr.meta.description;
      "org.opencontainers.image.licenses" = pkgs.radarr.meta.license.spdxId;
    };
    User = "1000:1000";
  };
  contents = [
    pkgs.dockerTools.fakeNss
  ];
  fakeRootCommands = ''
    mkdir -p ./var/lib/radarr/config
    chown 1000:1000 ./var/lib/radarr/config
    mkdir -p ./var/lib/radarr/data
    chown 1000:1000 ./var/lib/radarr/data
  '';
}
