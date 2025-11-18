{ base, pkgs }:

pkgs.dockerTools.streamLayeredImage {
  name = "postgresql";
  tag = pkgs.postgresql.version;
  fromImage = base;

  config = {
    Entrypoint = [
      "${pkgs.postgresql}/bin/postgres"
    ];
    Env = [
      "PGDATA=/var/lib/postgresql/data/${pkgs.postgresql.psqlSchema}"
    ];
    ExposedPorts = {
      "5432/tcp" = { }; # PostgreSQL default port
    };
    Labels = {
      "org.opencontainers.image.source" = "https://github.com/shikanime/niximgs";
      "org.opencontainers.image.description" = pkgs.postgresql.meta.description;
      "org.opencontainers.image.licenses" = pkgs.postgresql.meta.license.spdxId;
    };
    User = "1000:1000";
  };
  contents = [
    pkgs.dockerTools.fakeNss
    pkgs.postgresql
  ];
  fakeRootCommands = ''
    mkdir -p ./var/lib/postgresql/data/${pkgs.postgresql.psqlSchema}
    chown 1000:1000 ./var/lib/postgresql/data/${pkgs.postgresql.psqlSchema}
  '';
}
