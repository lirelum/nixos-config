#!/usr/bin/env bash
# 2つの git ref における NixOS system toplevel の導出を比較する。
#
# drvPath が同じなら、ビルド手順、入力、出力先は完全に同一である。
# 異なる場合は同一とは見なさず、nix-diff で差の原因を表示する。
# ビルド済みファイルから store hash を取り除く方法は、自己参照による差と
# 実際に異なる依存先を区別できないため使用しない。
#
# 使い方: diff-system-closure [old-ref] [new-ref] [host]
#   old-ref  比較元の git ref (デフォルト: HEAD)
#   new-ref  比較先の git ref。未コミットの作業ツリーは "." (デフォルト: .)
#   host     nixosConfigurations.<host>。省略時は /etc/hostname から現在の
#            ホスト名を推測し、flake に存在すればそれを使う。無ければ
#            ホストが1つだけの場合に限り自動検出する
set -euo pipefail

repo="$(git rev-parse --show-toplevel)"
old_ref="${1:-HEAD}"
new_ref="${2:-.}"
host="${3:-}"

flake_ref() {
  local ref="$1"
  if [[ "$ref" == "." ]]; then
    printf '%s\n' "$repo"
  else
    printf 'git+file://%s?rev=%s\n' "$repo" "$(git -C "$repo" rev-parse "$ref")"
  fi
}

old_flake="$(flake_ref "$old_ref")"
new_flake="$(flake_ref "$new_ref")"

if [[ -z "$host" ]]; then
  hosts="$(nix eval "$new_flake#nixosConfigurations" \
    --apply 'a: builtins.concatStringsSep " " (builtins.attrNames a)' --raw)"
  read -r -a host_list <<<"$hosts"

  if [[ -r /etc/hostname ]]; then
    read -r local_host < /etc/hostname
    for h in "${host_list[@]}"; do
      if [[ "$h" == "$local_host" ]]; then
        host="$local_host"
        break
      fi
    done
  fi

  if [[ -z "$host" ]]; then
    if [[ "${#host_list[@]}" -ne 1 ]]; then
      printf 'Multiple hosts found (%s); pass one as the third argument.\n' "$hosts" >&2
      exit 2
    fi
    host="${host_list[0]}"
  fi
fi

attr="nixosConfigurations.$host.config.system.build.toplevel.drvPath"

printf 'Evaluating %s @ [%s]...\n' "$host" "$old_ref" >&2
old_drv="$(nix eval --raw "$old_flake#$attr")"

printf 'Evaluating %s @ [%s]...\n' "$host" "$new_ref" >&2
new_drv="$(nix eval --raw "$new_flake#$attr")"

printf '\nold: %s\nnew: %s\n\n' "$old_drv" "$new_drv" >&2

if [[ "$old_drv" == "$new_drv" ]]; then
  printf 'Identical system derivation.\n' >&2
  exit 0
fi

printf 'System derivations differ:\n' >&2
nix-diff --skip-already-compared --word-oriented --context 2 "$old_drv" "$new_drv"
exit 1
