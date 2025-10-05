{ base, pkgs }:

pkgs.dockerTools.buildLayeredImage {
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
      "org.opencontainers.image.source" = "https://github.com/shikanime/niximgs";
      "org.opencontainers.image.description" = pkgs.mlflow-server.meta.description;
      "org.opencontainers.image.licenses" = pkgs.mlflow-server.meta.license.spdxId;
    };
    User = "mlflow";
  };
  fakeRootCommands = ''
    #!${pkgs.runtimeShell}
    ${pkgs.dockerTools.shadowSetup}
    groupadd -r mlflow
    useradd -r -g mlflow mlflow
  '';
}
