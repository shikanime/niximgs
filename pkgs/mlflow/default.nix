{ base, pkgs }:

pkgs.dockerTools.streamLayeredImage {
  name = "mlflow";
  tag = pkgs.mlflow-server.version;
  fromImage = base;

  config = {
    Cmd = [
      "server"
    ];
    Entrypoint = [
      "${pkgs.mlflow-server}/bin/mlflow"
    ];
    Env = [
      "PATH=${pkgs.mlflow-server}/bin"
    ];
    Labels = {
      "org.opencontainers.image.source" = "https://github.com/shikanime/niximgs";
      "org.opencontainers.image.description" = pkgs.mlflow-server.meta.description;
      "org.opencontainers.image.licenses" = pkgs.mlflow-server.meta.license.spdxId;
    };
    User = "1000:1000";
  };
  contents = [
    pkgs.mlflow-server
  ];
}
