{lib, ...}: {
  sops = {
    defaultSopsFile = lib.TM.get-secret-file "generic.yaml";
    age = {
      sshKeyPaths = lib.mkDefault ["/etc/ssh/ssh_host_ed25519_key"];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
  };
}
