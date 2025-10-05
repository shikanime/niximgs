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
      "org.opencontainers.image.description" = pkgs.sonarr.meta.description;
      "org.opencontainers.image.licenses" = pkgs.sonarr.meta.license.spdxId;
    };
  };
  extraCommands = ''
    mkdir -p var/lib/sonarr
  '';
}
