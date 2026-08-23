#!/usr/bin/env bash
# Build a host's system toplevel at two git refs and diff the resulting store
# closures, to confirm a refactor didn't change what actually gets built.
#
# `nix store diff-closures` alone isn't enough for this: it's a name+version
# heuristic over store-path basenames, not a content diff, so it can go quiet
# on paths that don't parse as a recognizable package (etc/nix/registry.json,
# activate, switch-to-configuration, ...) regardless of whether they actually
# differ. Every NixOS system closure also embeds its own store path in several
# generated files (activate, switch-to-configuration, boot.json, ...), so two
# builds that are behaviorally identical will still differ there byte-for-byte
# purely from that unavoidable self-reference.
#
# So this combines two checks. diff-closures still does the package-level job
# it's actually good at (an added/removed/version-bumped package, like the
# whole `sw` profile symlink pointing at a different system-path derivation
# because a package was added - normalizing that symlink's target away would
# be wrong, since the hash difference IS the signal there). Separately, this
# script does its own byte diff of only the toplevel's own directly-generated
# *regular* files (not symlinks - those point at other derivations already
# covered by diff-closures), normalizing away /nix/store/<hash>- prefixes
# first so the files' unavoidable self-reference doesn't look like a real
# difference. Something is only reported clean if both checks are.
#
# Usage: diff-system-closure.sh [old-ref] [new-ref] [host]
#   old-ref  git ref to build "before" from (default: HEAD)
#   new-ref  git ref to build "after" from, or "." for the working tree
#            as-is, including uncommitted changes (default: .)
#   host     nixosConfigurations.<host> to build (default: autodetected if
#            there's exactly one)
set -euo pipefail

repo="$(git rev-parse --show-toplevel)"
old_ref="${1:-HEAD}"
new_ref="${2:-.}"
host="${3:-}"

if [[ -z "$host" ]]; then
  hosts="$(nix eval "$repo#nixosConfigurations" --apply 'a: builtins.concatStringsSep " " (builtins.attrNames a)' --raw)"
  if [[ "$(wc -w <<<"$hosts")" -ne 1 ]]; then
    echo "Multiple hosts found ($hosts) - pass one explicitly as the third argument." >&2
    exit 1
  fi
  host="$hosts"
fi

flake_ref() {
  local ref="$1"
  if [[ "$ref" == "." ]]; then
    echo "$repo"
  else
    echo "git+file://$repo?rev=$(git -C "$repo" rev-parse "$ref")"
  fi
}

attr="nixosConfigurations.$host.config.system.build.toplevel"

echo "Building $host @ $old_ref..." >&2
old_path="$(nix build --no-link --print-out-paths "$(flake_ref "$old_ref")#$attr")"

echo "Building $host @ $new_ref..." >&2
new_path="$(nix build --no-link --print-out-paths "$(flake_ref "$new_ref")#$attr")"

echo >&2
echo "old: $old_path" >&2
echo "new: $new_path" >&2
echo >&2

if [[ "$old_path" == "$new_path" ]]; then
  echo "Identical store path - no differences possible." >&2
  exit 0
fi

real_diff=0

echo "Package-level summary (nix store diff-closures - name/version changes only):" >&2
package_diff="$(nix store diff-closures "$old_path" "$new_path")"
if [[ -n "$package_diff" ]]; then
  echo "$package_diff"
  real_diff=1
fi
echo >&2

normalize() {
  sed -E 's#/nix/store/[0-9a-z]{32}-#/nix/store/HASH-#g'
}

# Relative paths of the toplevel's own directly-generated regular files, NOT
# following symlinks - those point at other derivations (packages, etc/, the
# kernel, ...) whose content is diff-closures' job, not a byte-for-byte diff
# here, and normalizing a symlink's target hash away would wrongly hide a
# real change (the target hash differing IS the signal, unlike inline text).
list_regular_files() {
  find "$1" -type f -printf '%P\0'
}

echo "File-level diff of the toplevel's own generated files (hashes normalized):" >&2

while IFS= read -r -d '' rel; do
  old_f="$old_path/$rel"
  new_f="$new_path/$rel"

  if [[ ! -e "$new_f" ]]; then
    echo "removed: $rel"
    real_diff=1
    continue
  fi

  if ! diff -q <(normalize <"$old_f") <(normalize <"$new_f") >/dev/null 2>&1; then
    echo "REAL diff: $rel"
    real_diff=1
  fi
done < <(list_regular_files "$old_path")

while IFS= read -r -d '' rel; do
  [[ -e "$old_path/$rel" ]] || {
    echo "added: $rel"
    real_diff=1
  }
done < <(list_regular_files "$new_path")

echo >&2
if [[ "$real_diff" -eq 0 ]]; then
  echo "No real differences" >&2
else
  echo "Real differences found (see above)" >&2
  exit 1
fi
