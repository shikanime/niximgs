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
    Labels = {
      "org.opencontainers.image.description" = pkgs.radarr.meta.description;
      "org.opencontainers.image.licenses" = pkgs.radarr.meta.license.spdxId;
    };
  };
  contents = [
    pkgs.dockerTools.fakeNss
  ];
  extraCommands = ''
    mkdir -p var/lib/radarr
  '';
}
