{ base, pkgs }:

pkgs.dockerTools.buildLayeredImage {
  name = "redis";
  tag = pkgs.redis.version;
  fromImage = base;

  config = {
    Entrypoint = [
      "${pkgs.redis}/bin/redis-server"
    ];
    ExposedPorts = {
      "6379/tcp" = { }; # Redis default port
    };
    Labels = {
      "org.opencontainers.image.source" = "https://github.com/shikanime/niximgs";
      "org.opencontainers.image.description" = pkgs.redis.meta.description;
      "org.opencontainers.image.licenses" = pkgs.redis.meta.license.spdxId;
    };
    User = "1000:1000";
  };
  contents = [
    pkgs.dockerTools.fakeNss
    pkgs.redis
  ];
  fakeRootCommands = ''
    mkdir -p ./var/lib/redis
    chown 1000:1000 ./var/lib/redis
  '';
}
