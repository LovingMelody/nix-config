{
  lib,
  rustPlatform,
  fetchFromGitHub,
  ...
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "slower";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "LovingMelody";
    repo = "slower";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-cNnU4I6u5Ual1RBehCJxYJ1d/7nbZaZJNOVfhuPqYHM=";
  };
  cargoLock.lockFile = finalAttrs.src + "/Cargo.lock";

  meta = {
    description = "Rate limit stdout";
    longDescription = "Rate limit stdout output to make logs readable";
    homepage = "https://github.com/lovingmelody/slower";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [fuzen];
  };
})
