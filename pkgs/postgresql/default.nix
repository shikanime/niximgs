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
    User = "postgres";
    Labels = {
      "org.opencontainers.image.description" = pkgs.postgresql.meta.description;
      "org.opencontainers.image.licenses" = pkgs.postgresql.meta.license.spdxId;
    };
  };
  fakeRootCommands = ''
    ${pkgs.dockerTools.shadowSetup}
    groupadd -r postgres
    useradd -r -g postgres postgres
    mkdir var/lib/postgresql
    chown postgres:postgres var/lib/postgresql
  '';
}
