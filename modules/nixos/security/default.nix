{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.TM.security;
  inherit
    (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    ;
in {
  options.TM.security = {
    enable =
      mkEnableOption "Enable security defaults"
      // {
        default = true;
      };
    enableTPM =
      mkEnableOption "Enable TPM"
      // {
        default = false;
      };
    enableSecureBoot =
      mkEnableOption "Enable Secure Boot"
      // {
        default = false;
      };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      security = {
        sudo.enable = false;
        sudo-rs = {
          execWheelOnly = true;
          enable = true;
        };
      };

      services.pcscd.enable = true;
      networking.firewall.enable = true;
      boot = {
        kernel.sysctl = {
          "dev.tty.ldisc_autoload" = 0; # Restricts loading TTY line disciplines to CAP_SYS_MODULE
          "fs.protected_fifos" = 2; # Prevent creating files in potential attacker controled environment
          "fs.protected_hardlinks" = 1; # Only allows symlinks to eb followed when outside of a world readible sticky directory
          "fs.protected_regular" = 2; # Prevent creating files in potential attacker controled environment
          "fs.protected_symlinks" = 1; # Only allows symlinks to eb followed when outside of a world readible sticky directory
          "fs.suid_dumpable" = 0; # Prevents process to dump their suid
          "kernel.dmesg_restrict" = 1; # Prevents dmsg leaking sensitive info
          "kernel.kexec_load_disabled" = 1; # Prevents system call from allowing another kernel during runtime
          "kernel.kptr_restrict" = 2; # can be set to 1 to only hide kernel pointers
          "kernel.perf_event_paranoid" = 3; # Perf events add attack surface
          "kernel.printk" = "3 3 3 3"; # Prevents kernel log printing during boot
          "kernel.sysrq" = 0; # Magic SysRq key not needed - potential security concern.
          # "kernel.unprivileged_userns_clone" = 0; # Reduces priveledge escelation exploits but may break things
          # "kernel.unprivileged_bpf_disabled" = 1; # https://www.suse.com/support/kb/doc/?id=000020545
          "kernel.core_pattern" = "|/bin/false"; # Pretty sure this is the systemd default anyways
          # "kernel.yama.ptrace_scope" = 3; # Restrict ptrace
          # "kernel.io_uring_disabled" = 2; # Might be needed for proxmux but exploitable and disabled on Android+ChromeOS
          "kernel.randomize_va_space" = 2; # I think this is the default anyways
          "net.core.default_qdisc" = "cake";
          "net.core.bpf_jit_harden" = 2;
          # "net.ipv4.ip_forward" = 0; # Needed for VMS
          # "net.ipv4.conf.all.forwarding" = 0; # Needed for VMs
          # "net.ipv4.conf.default.forwarding" = 0; # Needed for VMs
          # "net.ipv6.conf.all.forwarding" = 0; # Needed for VMs
          # "net.ipv6.conf.default.forwarding" = 0; # Needed for VMs
          "net.ipv4.conf.all.accept_redirects" = 0; # Refuse ICMP redirects (MITM Mitigation)
          "net.ipv4.conf.all.accept_source_route" = 0; # Reject IP Source route packets (router things)
          "net.ipv4.conf.all.rp_filter" = 1; # Reverse paath filter prevent IP spoofing
          "net.ipv4.conf.all.secure_redirects" = 0; # Refuse ICMP redirects (MITM Mitigation)
          "net.ipv4.conf.all.send_redirects" = 0; # Don't send ICMP redirects (router things)
          "net.ipv4.conf.default.accept_redirects" = 0; # Refuse ICMP redirects (MITM Mitigation)
          "net.ipv4.conf.default.rp_filter" = 1; # Reverse paath filter prevent IP spoofing
          "net.ipv4.conf.default.secure_redirects" = 0; # Refuse ICMP redirects (MITM Mitigation)
          "net.ipv4.conf.default.send_redirects" = 0; # Don't ICMP redirects (router things)
          "net.ipv4.icmp_echo_ignore_all" = 1; # Prevents smurf attacks
          "net.ipv4.icmp_ignore_bogus_error_responses" = 1; # Log cleanup
          "net.ipv4.tcp_congestion_control" = "bbr"; # Bufferbloat :D
          "net.ipv4.tcp_dsack" = 0; # Disable TCP Sack, exploitable and not needed
          "net.ipv4.tcp_fack" = 0; # Disable TCP Sack, exploitable and not needed
          "net.ipv4.tcp_fastopen" = 3; # Enable fast open - reduce network latency
          "net.ipv4.tcp_rfc1337" = 1; # Partial protection against TIME-WAIT assasination
          "net.ipv4.tcp_sack" = 0; # Disable TCP Sack, exploitable and not needed
          "net.ipv4.tcp_syncookies" = 1; # Syn flood attack protection
          "net.ipv4.tcp_timestamps" = 1; # Disable TCP timestamps to avoid leaking system time
          "net.ipv6.conf.all.accept_ra" = 0; # IPV6 router advertisment disable
          "net.ipv6.conf.all.accept_redirects" = 0; # Refuse ICMP redirects (MITM Mitigation)
          "net.ipv6.conf.all.accept_source_route" = 0; # Reject IP source route packets (router things)
          "net.ipv6.conf.default.accept_ra" = 0; # IPV6 router advertisment disable
          "net.ipv6.conf.default.accept_redirects" = 0; # Refuse ICMP redirects (MITM Mitigation)
          "vm.mmap_rnd_bits" = 32; # Increase entropy for mmap ASLR
          "vm.mmap_rnd_compat_bits" = 16; # Increase entropy for mmap ASLR
          "vm.swappiness" = mkDefault 1; # VM swap only when necessary
          "vm.unprivileged_userfaultfd" = 0; # Restrict userdefaultfd to CAP_SYS_PTRACE to prevent use after free flaws
        };
        kernelModules = ["tcp_bbr"];
        kernelParams = [
          "init_on_alloc=1" # Enables zeroing of memory
          "init_on_free=1" # Enables zeroing of memory
          "page_alloc.shuffle=1" # Randomizes page allocator freelist (Also improves performance)
          "randomize_kstack_offset=on" # Randomizes kernel stack offset makes CVE-2019-18683 more difficult
          "vsyscall=none" # Obsolete replaced with vDSO
          "debugfs=off" # Exposes lot of sensitive info about kernel when on
          "oops=panic" # Prevents exploits that cause oops
          "quiet" # Prevent info leaks during boot w/ kernel.printk
          "loglevel=0" # Prevent info leaks during boot w/ kernel.printk
          "intel_iommu=on"
          "amd_iommu=force_isolation"
          "iommu=force"
          "iommu.passthrough=0"
          "iommu.strict=1"
        ];
      };
    })
    (mkIf cfg.enableTPM {
      boot.initrd.availableKernelModules = ["tpm_tis"];
      security.tpm2 = {
        enable = true;
        pkcs11.enable = true;
        tctiEnvironment.enable = true;
      };
    })
    (mkIf cfg.enableSecureBoot {
      environment.systemPackages = [pkgs.sbctl];
      boot = {
        loader.systemd-boot.enable = lib.mkForce false;
        lanzaboote = {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
        };
      };
    })
  ];
}
