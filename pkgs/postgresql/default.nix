{ base, pkgs }:

pkgs.dockerTools.buildLayeredImage {
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
    User = "1000:1000";
    Labels = {
      "org.opencontainers.image.description" = pkgs.postgresql.meta.description;
      "org.opencontainers.image.licenses" = pkgs.postgresql.meta.license.spdxId;
    };
  };
  fakeRootCommands = ''
    mkdir -p var/lib/postgresql/data
    chown 1000:1000 ./var/lib/postgresql/data
  '';
}
