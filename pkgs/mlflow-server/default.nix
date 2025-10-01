{ pkgs }:

pkgs.dockerTools.buildLayeredImage {
  name = "mlflow-server";
  tag = pkgs.mlflow-server.version;

  config = {
    Entrypoint = [
      "${pkgs.mlflow-server}/bin/mlflow"
    ];
    Cmd = [
      "server"
    ];
    Labels = {
      "org.opencontainers.image.source" = "https://github.com/shikanime/niximgs";
      "org.opencontainers.image.description" = pkgs.mlflow-server.meta.description;
      "org.opencontainers.image.licenses" = pkgs.mlflow-server.meta.license.spdxId;
    };
  };
  contents = [
    pkgs.dockerTools.caCertificates
  ];
}