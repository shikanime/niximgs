{ base, pkgs }:

pkgs.dockerTools.buildLayeredImage {
  name = "sonarr";
  tag = pkgs.sonarr.version;
  fromImage = base;

  config = {
    Entrypoint = [
      "${pkgs.sonarr}/bin/Sonarr"
    ];
    Cmd = [
      "-nobrowser"
      "-data"
      "/var/lib/sonarr/data"
    ];
    ExposedPorts = {
      "8989/tcp" = { }; # Web UI
    };
    Env = [
      "XDG_CONFIG_HOME=/var/lib/sonarr/config"
    ];
    Labels = {
      "org.opencontainers.image.source" = "https://github.com/shikanime/niximgs";
      "org.opencontainers.image.description" = pkgs.sonarr.meta.description;
      "org.opencontainers.image.licenses" = pkgs.sonarr.meta.license.spdxId;
    };
    User = "1000:1000";
  };
  contents = [
    pkgs.dockerTools.fakeNss
  ];
  fakeRootCommands = ''
    mkdir -p ./var/lib/sonarr/config
    chown 1000:1000 ./var/lib/sonarr/config
    mkdir -p ./var/lib/sonarr/data
    chown 1000:1000 ./var/lib/sonarr/data
  '';
}
