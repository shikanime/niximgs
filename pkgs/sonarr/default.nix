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
      "/var/lib/sonarr"
    ];
    ExposedPorts = {
      "8989/tcp" = { }; # Web UI
    };
    Labels = {
      "org.opencontainers.image.source" = "https://github.com/shikanime/niximgs";
      "org.opencontainers.image.description" = pkgs.sonarr.meta.description;
      "org.opencontainers.image.licenses" = pkgs.sonarr.meta.license.spdxId;
    };
    User = "sonarr";
  };
  contents = [
    pkgs.dockerTools.fakeNss
  ];
  fakeRootCommands = ''
    #!${pkgs.runtimeShell}
    ${pkgs.dockerTools.shadowSetup}
    groupadd -r sonarr
    useradd -r -g sonarr sonarr
    mkdir -p ./var/lib/sonarr
    chown sonarr:sonarr ./var/lib/sonarr
  '';
}
