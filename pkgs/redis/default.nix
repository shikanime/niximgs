{ pkgs }:

pkgs.dockerTools.buildLayeredImage {
  name = "redis";
  tag = pkgs.redis.version;

  config = {
    Cmd = [
      "${pkgs.redis}/bin/redis-server"
    ];
    ExposedPorts = {
      "6379/tcp" = { }; # Redis default port
    };
    Env = [
      "REDIS_DATA_DIR=/data"
    ];
    User = "999:999"; # redis user
    WorkingDir = "/data";
  };
  contents = [
    pkgs.dockerTools.caCertificates
  ];
}