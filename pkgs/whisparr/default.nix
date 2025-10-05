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
    User = "whisparr";
  };
  contents = [
    pkgs.dockerTools.fakeNss
  ];
  fakeRootCommands = ''
    #!${pkgs.runtimeShell}
    ${pkgs.dockerTools.shadowSetup}
    groupadd -r whisparr
    useradd -r -g whisparr whisparr
    mkdir -p ./var/lib/whisparr/config
    chown whisparr:whisparr ./var/lib/whisparr/config
    mkdir -p ./var/lib/whisparr/data
    chown whisparr:whisparr ./var/lib/whisparr/data
  '';
}
