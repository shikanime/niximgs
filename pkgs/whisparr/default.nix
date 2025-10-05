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
      "org.opencontainers.image.description" = pkgs.whisparr.meta.description;
      "org.opencontainers.image.licenses" = pkgs.whisparr.meta.license.spdxId;
    };
  };
  contents = [
    pkgs.dockerTools.fakeNss
  ];
  extraCommands = ''
    mkdir -p var/lib/whisparr
  '';
}
