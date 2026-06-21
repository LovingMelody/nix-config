#!/usr/bin/env nix-shell
#! nix-shell -i bash
#! nix-shell -p bash jaq
INFO="./modules/nixos/vr/wivrn-apk.json"
VERSION="$(nix eval .#nixosConfigurations.Snow.pkgs.wivrn.version --raw 2>/dev/null)"
# Don't needlessly update
if [ "$(jaq -r .version <"$INFO")" == "$VERSION" ]; then
  exit 0
fi
WIVRN_APK_URL="https://github.com/WiVRn/WiVRn-APK/releases/download/apk-$VERSION/org.meumeu.wivrn-release.apk"
HASH="$(nix store prefetch-file --hash-type sha512 "$WIVRN_APK_URL" --json | jaq -r .hash)"
if [ "$HASH" == "" ]; then
  echo "Failed to fetch hash for \`$WIVRN_APK_URL\`"
  exit 1
fi
jaq -n --arg url "$WIVRN_APK_URL" --arg hash "$HASH" --arg version "$VERSION" \
  '{version: $version, hash: $hash, url: $url}' >"$INFO"
