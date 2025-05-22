{
  lib,
  buildNimPackage,
  fetchFromGitHub,
  nix-update-script,
}:
buildNimPackage (finalAttrs: {
  pname = "nitch";
  version = "git+${builtins.substring 0 8 finalAttrs.src.rev}";
  src = fetchFromGitHub {
    owner = "LovingMelody";
    repo = "nitch";
    rev = "330414b5cf0620346ccd7eef20caad9fe41caffd";
    hash = "sha256-FpNEEalCEspB4LvDLVPTqHfzyfmyb/9pwtc/+WLkS7I=";
  };

  passthru.updateScript = nix-update-script {extraArgs = ["--version=branch"];};

  meta = {
    description = "A fork of the incredibly fast system fetch written in nim";
    homepage = "https://github.com/lovingmelody/nitch";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [fuzen];
    mainProgram = "nitch";
  };
})
