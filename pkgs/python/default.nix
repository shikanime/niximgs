{ pkgs }:

pkgs.dockerTools.buildLayeredImage {
  name = "python";
  tag = pkgs.python3.version;

  config = {
    Entrypoint = [
      "${pkgs.python3}/bin/python"
    ];
    Labels = {
      "org.opencontainers.image.source" = "https://github.com/shikanime/niximgs";
      "org.opencontainers.image.description" = pkgs.python3.meta.description;
      "org.opencontainers.image.licenses" = pkgs.python3.meta.license.spdxId;
    };
  };
  contents = [
    pkgs.dockerTools.caCertificates
    pkgs.dockerTools.usrBinEnv
    pkgs.dockerTools.binSh
    pkgs.coreutils
    pkgs.bash
    pkgs.python3
  ];
}