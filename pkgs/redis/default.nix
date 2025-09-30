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
    User = "999:999"; # redis user
  };
  contents = [
    pkgs.dockerTools.caCertificates
  ];
}
