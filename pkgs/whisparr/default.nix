{ base, pkgs }:

pkgs.dockerTools.buildLayeredImage {
  name = "whisparr";
  tag = pkgs.whisparr.version;
  fromImage = base;

  config = {
    Entrypoint = [
      "${pkgs.whisparr}/bin/Whisparr"
    ];
    Cmd = [
      "-nobrowser"
      "-data"
      "/var/lib/whisparr/data"
    ];
    ExposedPorts = {
      "6969/tcp" = { }; # Web UI
    };
    Env = [
      "XDG_CONFIG_HOME=/var/lib/whisparr/config"
    ];
    Labels = {
      "org.opencontainers.image.source" = "https://github.com/shikanime/niximgs";
      "org.opencontainers.image.description" = pkgs.whisparr.meta.description;
      "org.opencontainers.image.licenses" = pkgs.whisparr.meta.license.spdxId;
    };
    User = "1000:1000";
  };
  contents = [
    pkgs.dockerTools.fakeNss
  ];
  fakeRootCommands = ''
    mkdir -p ./var/lib/whisparr/config
    chown 1000:1000 ./var/lib/whisparr/config
    mkdir -p ./var/lib/whisparr/data
    chown 1000:1000 ./var/lib/whisparr/data
  '';
}
