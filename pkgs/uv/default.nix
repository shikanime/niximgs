{ pkgs }:

pkgs.dockerTools.buildLayeredImage {
  name = "uv";
  tag = pkgs.uv.version;

  config = {
    Entrypoint = [
      "${pkgs.uv}/bin/uv"
    ];
    Labels = {
      "org.opencontainers.image.source" = "https://github.com/shikanime/niximgs";
      "org.opencontainers.image.description" = pkgs.uv.meta.description;
      "org.opencontainers.image.licenses" = pkgs.lib.concatStringsSep "," (
        map (l: l.spdxId) pkgs.uv.meta.license
      );
    };
  };
  contents = [
    pkgs.dockerTools.caCertificates
  ];
}
