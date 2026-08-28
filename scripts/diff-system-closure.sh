#!/usr/bin/env bash
# 2つの git ref でホストの system toplevel をビルドし、生成されたストアの
# クロージャを diff することで、リファクタリングによって実際にビルドされる
# ものが変わっていないかを確認する。
#
# これには `nix store diff-closures` だけでは不十分: これはストアパスの
# basename に対する名前+バージョンのヒューリスティックであり、内容の diff
# ではない。そのため、認識可能なパッケージとしてパースできないパス
# (etc/nix/registry.json, activate, switch-to-configuration, ...) では、
# 実際に差分があるかどうかに関わらず何も検出されないことがある。また、
# すべての NixOS システムクロージャは、いくつかの生成ファイル
# (activate, switch-to-configuration, boot.json, ...) の中に自分自身の
# ストアパスを埋め込んでいるため、動作的には同一の2つのビルドであっても、
# この避けようのない自己参照だけが原因でバイト単位では差分が生じてしまう。
#
# そこでこのスクリプトは2つのチェックを組み合わせる。diff-closures には
# 引き続き、それが本来得意とするパッケージレベルの仕事
# (パッケージの追加/削除/バージョン変更、たとえばパッケージが追加された
# ことで `sw` プロファイルのシンボリックリンク全体が別の system-path
# 導出を指すようになる場合など - このシンボリックリンクのリンク先を
# 正規化して差分を消してしまうのは誤りで、そのハッシュの違いこそが
# ここでのシグナルそのものだから)を任せる。それとは別に、このスクリプトは
# toplevel が直接生成する*通常ファイル*(シンボリックリンクは除く -
# それらは別の導出を指しており、すでに diff-closures がカバー済み)
# についてのみ、独自にバイト単位の diff を行う。その際まず
# /nix/store/<hash>- というプレフィックスを正規化して取り除き、
# ファイルの避けようのない自己参照が実際の差分に見えてしまわないように
# する。両方のチェックがクリーンな場合にのみ「差分なし」と報告される。
#
# 使い方: diff-system-closure.sh [old-ref] [new-ref] [host]
#   old-ref  「変更前」をビルドする git ref (デフォルト: HEAD)
#   new-ref  「変更後」をビルドする git ref。作業ツリーをコミットしていない
#            変更も含めてそのままビルドする場合は "." を指定
#            (デフォルト: .)
#   host     ビルド対象の nixosConfigurations.<host>
#            (デフォルト: 該当するホストが1つだけの場合は自動検出)
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

# toplevel が直接生成する通常ファイルの相対パス。シンボリックリンクは
# たどらない - それらは別の導出 (パッケージ, etc/, カーネル, ...) を
# 指しており、その内容の diff は diff-closures の仕事であって、ここで
# バイト単位の diff をする対象ではない。また、シンボリックリンクの
# リンク先ハッシュを正規化して消してしまうと、本物の変更を誤って
# 隠してしまう(インラインのテキストとは違い、リンク先ハッシュの違い
# こそがここでのシグナルそのものである)。
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
