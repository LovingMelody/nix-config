# We can make use of the facter report to auto enable or disable
# Things without hand enabling them per host as hardware changes
# Won't work for things like HDR but it will help for other things
# Facter doesnt need to be enabled to be useful and causes problems
# if it is enabled
{
  config,
  lib,
  inputs,
  host,
  ...
}: let
  inherit
    (lib)
    all
    any
    elem
    filter
    head
    length
    mkDefault
    mkIf
    mkOption
    optional
    toList
    types
    ;
  reportPath = "${inputs.self}/systems/${host}/facter.json";
  inherit (config.hardware.facter) report detected;
  hw = report.hardware or {};
  info = config.TM.hardware;

  # hardware.system.form_factor is wrong on some machines (desktops showing up
  # as laptops), so use the smbios chassis type instead.
  # laptop: portable, laptop, notebook, sub notebook, tablet, convertible, detachable
  # desktop: desktop, low profile, pizza box, mini tower, tower, all in one,
  #          space saving, lunch box, sealed case, mini pc, stick pc
  chassisTypes = map (c: c.chassis_type.value or 0) (toList (report.smbios.chassis or []));
  chassis =
    if any (t: elem t [8 9 10 14 30 31 32]) chassisTypes
    then "laptop"
    else if any (t: elem t [3 4 5 6 7 13 15 16 24 35 36]) chassisTypes
    then "desktop"
    else null;

  # match on vendor id, driver can be nouveau or null depending on when the report was made
  gpus = vendor: filter (g: (g.vendor.value or 0) == vendor) (hw.graphics_card or []);
  nvidiaGpus = gpus 4318; # 10de
  amdGpus = gpus 4098; # 1002
  # an intel igpu disabled in the bios still shows up, only count it if a driver bound to it
  intelGpus = filter (g: any (d: elem d ["i915" "xe"]) (g.driver_modules or [])) (gpus 32902); # 8086

  # for prime, the report is hex but nixos wants decimal: 0000:0a:00.0 -> PCI:10:0:0
  busId = list: let
    m = builtins.match "[^:]+:([^:]+):([^.]+)\\.(.+)" ((head list).sysfs_bus_id or "");
    dec = i: toString (lib.fromHexString (builtins.elemAt m i));
  in
    if list == [] || m == null
    then null
    else "PCI:${dec 0}:${dec 1}:${dec 2}";

  cpu = head (hw.cpu or [{}]);
  family = cpu.family or 0;
  model = cpu.model or 0;
  isAmd = (cpu.vendor_name or null) == "AuthenticAMD";
  isIntel = (cpu.vendor_name or null) == "GenuineIntel";
  has = all (f: elem f (cpu.features or []));
  v3 = ["avx2" "bmi1" "bmi2" "fma" "movbe" "f16c" "abm" "xsave"];
  # amd family 23 = zen1/2 (model 48+ is zen2), 25 = zen3/4, 26 = zen5
  # zen4 in family 25 is models 0x10-0x1f and 0x60+
  # intel 151/154 alder lake, 190 alder lake-n, 183/186/191 raptor lake
  # anything else falls back to the x86-64 level from the cpu flags
  arch =
    if (report.system or "") != "x86_64-linux"
    then null
    else if isAmd && family == 23
    then
      (
        if model >= 48
        then "znver2"
        else "znver1"
      )
    else if isAmd && family == 25 && ((model >= 16 && model < 32) || model >= 96)
    then "znver4"
    else if isAmd && family == 25
    then "znver3"
    else if isAmd && family == 26
    then "znver5"
    else if isIntel && family == 6 && elem model [151 154 183 186 190 191]
    then "alderlake"
    else if has (v3 ++ ["avx512f" "avx512bw" "avx512cd" "avx512dq" "avx512vl"])
    then "x86-64-v4"
    else if has v3
    then "x86-64-v3"
    else "x86-64-v2";

  interfaces = detected.dhcp.interfaces;
in {
  options.TM.hardware = mkOption {
    type = types.attrs;
    readOnly = true;
    description = "Hardware info from the facter report";
    default = {
      hasReport = report != {};
      inherit chassis;
      gpu = {
        nvidia = nvidiaGpus != [];
        amd = amdGpus != [];
        intel = intelGpus != [];
        busIds = {
          nvidia = busId nvidiaGpus;
          amdgpu = busId amdGpus;
          intel = busId intelGpus;
        };
      };
      network = {inherit interfaces;};
      # mt7925e/ath12k only exist for wifi 7 cards, intel uses iwlwifi for everything so go by id:
      # mt7925, mt7927, intel be200, qualcomm wcn785x
      wifi7 = any (c:
        elem (c.driver or null) ["mt7925e" "ath12k"]
        || elem "${c.vendor.hex or ""}:${c.device.hex or ""}" ["14c3:7925" "14c3:7927" "8086:272b" "17cb:1107"])
      (hw.network_controller or []);
      nvme = any (d: (d.driver or null) == "nvme") (hw.disk or []);
      baremetal = detected.virtualisation.none.enable;
      cpu = {
        vendor = cpu.vendor_name or null;
        inherit family model arch;
        kvmModule =
          if elem "svm" (cpu.features or [])
          then "kvm-amd"
          else if elem "vmx" (cpu.features or [])
          then "kvm-intel"
          else null;
      };
    };
  };

  config = {
    hardware.facter = {
      reportPath = mkIf (builtins.pathExists reportPath) (mkDefault reportPath);
      enable = mkDefault false;
    };

    # mkIf per value, optionalAttrs here causes infinite recursion
    TM = {
      isLaptop = mkIf (info.hasReport && chassis != null) (mkDefault (chassis == "laptop"));
      isDesktop = mkIf (info.hasReport && chassis != null) (mkDefault (chassis == "desktop"));
      # only with one interface, desktops often have several
      defaultNetworkAdapter = mkIf (info.hasReport && length interfaces == 1) (mkDefault (head interfaces));
      nvidia.enable = mkIf info.hasReport (mkDefault info.gpu.nvidia);
      hasWifi7 = mkIf info.hasReport (mkDefault info.wifi7);
      simd.arch = mkIf (info.hasReport && arch != null) (mkDefault arch);
    };

    warnings = lib.optionals info.hasReport (
      optional (chassis != null && config.TM.isLaptop != (chassis == "laptop")) "TM.isLaptop doesn't match the facter report"
      ++ optional (config.TM.nvidia.enable != info.gpu.nvidia) "TM.nvidia.enable doesn't match the facter report"
      ++ optional (config.TM.hasWifi7 != info.wifi7) "TM.hasWifi7 doesn't match the facter report"
      ++ optional (config.TM.defaultNetworkAdapter != null && interfaces != [] && !elem config.TM.defaultNetworkAdapter interfaces) "TM.defaultNetworkAdapter isn't in the facter report"
      ++ optional (config.services.fprintd.enable && !detected.fingerprint.enable) "fprintd is enabled but the facter report has no supported fingerprint reader"
    );
  };
}
