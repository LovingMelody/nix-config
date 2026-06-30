_: {
  options.TM.topology = {};

  config = {
    topology.networks.home = {
      name = "Home Network";
      cidrv4 = "192.168.4.1/24";
    };
  };
}
