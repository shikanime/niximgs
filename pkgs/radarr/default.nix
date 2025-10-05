{ base, pkgs }:

pkgs.dockerTools.buildLayeredImage {
  name = "radarr";
  tag = pkgs.radarr.version;
  fromImage = base;

  config = {
    Entrypoint = [
      "${pkgs.radarr}/bin/Radarr"
    ];
    Cmd = [
      "-nobrowser"
      "-data"
      "/var/lib/radarr"
    ];
    ExposedPorts = {
      "7878/tcp" = { }; # Web UI
    };
    Env = [
      "XDG_CONFIG_HOME=/var/lib/radarr"
    ];
    Labels = {
      "org.opencontainers.image.source" = "https://github.com/shikanime/niximgs";
      "org.opencontainers.image.description" = pkgs.radarr.meta.description;
      "org.opencontainers.image.licenses" = pkgs.radarr.meta.license.spdxId;
    };
    User = "radarr";
  };
  contents = [
    pkgs.dockerTools.fakeNss
  ];
  fakeRootCommands = ''
    #!${pkgs.runtimeShell}
    ${pkgs.dockerTools.shadowSetup}
    groupadd -r radarr
    useradd -r -g radarr radarr
    mkdir -p ./var/lib/radarr
    chown radarr:radarr ./var/lib/radarr
  '';
}
