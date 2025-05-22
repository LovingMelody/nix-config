{
  lib,
  rustPlatform,
  fetchFromGitHub,
  ...
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "slower";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "LovingMelody";
    repo = "slower";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-gQeQqXPjZDGJTnU3v2Xkxnw5F2KYvxwZjHDK2JOJ7OI=";
  };

  cargoSha256 = "04mbjikjwq2w6l2yx60y50ppdnw3l6y9bawik2hy6bq68ajnzvsv";

  meta = {
    description = "Rate limit stdout";
    longDescription = "Rate limit stdout output to make logs readable";
    homepage = "https://github.com/lovingmelody/slower";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [fuzen];
  };
})
