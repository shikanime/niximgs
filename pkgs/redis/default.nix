{ base, pkgs }:

pkgs.dockerTools.streamLayeredImage {
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
      "org.opencontainers.image.description" = pkgs.redis.meta.description;
      "org.opencontainers.image.licenses" = pkgs.redis.meta.license.spdxId;
    };
  };
}
