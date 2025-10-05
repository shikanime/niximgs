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
      "/var/lib/whisparr"
    ];
    ExposedPorts = {
      "6969/tcp" = { }; # Web UI
    };
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
    mkdir -p ./var/lib/whisparr
    chown 1000:1000 ./var/lib/whisparr
  '';
}
