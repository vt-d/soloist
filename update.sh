#!/usr/bin/env bash
# Bump the hash and version in package.nix to match Spotify's current build.
# Exits 0 either way; sets "changed=true|false" in $GITHUB_OUTPUT when present.
set -euo pipefail

cd "$(dirname "$0")"

emit() {
  echo "$1"
  if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    echo "changed=$2" >>"$GITHUB_OUTPUT"
    echo "version=${3:-}" >>"$GITHUB_OUTPUT"
  fi
}

url=$(sed -nE 's/^[[:space:]]*url = "([^"]+)";/\1/p' package.nix)
old_hash=$(sed -nE 's/^[[:space:]]*hash = "([^"]+)";/\1/p' package.nix)
old_version=$(sed -nE 's/^[[:space:]]*version = "([^"]+)";/\1/p' package.nix)

for v in url old_hash old_version; do
  [[ -n "${!v}" ]] || { echo "could not read $v from package.nix" >&2; exit 1; }
done

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

curl -fsSL --retry 3 -o "$tmp" "$url"
new_hash=$(nix hash file --type sha256 --sri "$tmp")

if [[ "$new_hash" == "$old_hash" ]]; then
  emit "soloist $old_version is up to date ($old_hash)" false "$old_version"
  exit 0
fi

sed -i "s|hash = \"$old_hash\";|hash = \"$new_hash\";|" package.nix

# --version reports the real build number; the stale version in the derivation name doesn't matter here.
out=$(nix build "path:$PWD#soloist" --no-link --print-out-paths)
new_version=$("$out/bin/soloist" --version | sed -nE 's/^soloist ([0-9][0-9.]*) .*/\1/p')
[[ -n "$new_version" ]] || { echo "could not parse version from soloist --version" >&2; exit 1; }

sed -i "s|version = \"$old_version\";|version = \"$new_version\";|" package.nix

# Rebuild so the committed state is the one proven to build.
nix build "path:$PWD#soloist" --no-link

emit "soloist $old_version -> $new_version ($old_hash -> $new_hash)" true "$new_version"
