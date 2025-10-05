{ base, pkgs }:

pkgs.dockerTools.streamLayeredImage {
  name = "mlflow";
  tag = pkgs.mlflow-server.version;
  fromImage = base;

  config = {
    Entrypoint = [
      "${pkgs.mlflow-server}/bin/mlflow"
    ];
    Cmd = [
      "server"
    ];
    Labels = {
      "org.opencontainers.image.description" = pkgs.mlflow-server.meta.description;
      "org.opencontainers.image.licenses" = pkgs.mlflow-server.meta.license.spdxId;
    };
  };
}
