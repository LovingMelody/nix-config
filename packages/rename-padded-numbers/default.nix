{
  rustPlatform,
  fetchFromGitHub,
  ...
}:
rustPlatform.buildRustPackage {
  pname = "rename-padded-numbers";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "LovingMelody";
    repo = "rename_padded_numbers";
    rev = "836a178bd1d0e0ea4724662c701d951f94ba3446";
    hash = "sha256-de82lG5P+C0FLGKyzf/MUre8XnwQ4w44syzIZhCpqsc=";
  };

  cargoHash = "sha256-FrVBt3by+Tz3dgTHReAqA4M6olwzrdWJRmJG0IMBMNg=";

  meta = {
    description = "A batch file renamer padding the first number with 0s for all files in CWD";
    homepage = "https://github.com/Fuzen-py/rename_padded_numbers";
  };
}
