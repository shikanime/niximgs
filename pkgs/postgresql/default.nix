{ pkgs }:

let
  dataDir = "/var/lib/postgresql/data";
in
pkgs.dockerTools.buildLayeredImage {
  name = "postgresql";
  tag = pkgs.postgresql.version;

  config = {
    Entrypoint = [
      "${pkgs.postgresql}/bin/postgres"
    ];
    ExposedPorts = {
      "5432/tcp" = { }; # PostgreSQL default port
    };
    Env = [
      "POSTGRES_DB=postgres"
      "POSTGRES_USER=postgres"
      "POSTGRES_PASSWORD=postgres"
      "PGDATA=${dataDir}"
    ];
    Labels = {
      "org.opencontainers.image.source" = "https://github.com/shikanime/niximgs";
      "org.opencontainers.image.description" = pkgs.postgresql.meta.description;
      "org.opencontainers.image.licenses" = pkgs.postgresql.meta.license.spdxId;
    };
  };
  contents = [
    pkgs.dockerTools.caCertificates
  ];
  extraCommands = ''
    mkdir -p ${dataDir}
  '';
}
