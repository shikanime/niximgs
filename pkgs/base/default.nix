{ pkgs }:

pkgs.dockerTools.buildLayeredImage {
  name = "base";

  config = {
    Labels = {
      "org.opencontainers.image.source" = "https://github.com/shikanime/niximgs";
      "org.opencontainers.image.description" = "Niximgs base image";
      "org.opencontainers.image.licenses" = pkgs.lib.licenses.asl20;
    };
  };
  contents = [
    pkgs.dockerTools.caCertificates
  ];
}
