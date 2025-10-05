{ base, pkgs }:

pkgs.dockerTools.streamLayeredImage {
  name = "postgresql";
  tag = pkgs.postgresql.version;
  fromImage = base;

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
      "PGDATA=/var/lib/postgresql/data"
    ];
    Labels = {
      "org.opencontainers.image.description" = pkgs.postgresql.meta.description;
      "org.opencontainers.image.licenses" = pkgs.postgresql.meta.license.spdxId;
    };
  };
  extraCommands = ''
    mkdir -p var/lib/postgresql/data
  '';
}
