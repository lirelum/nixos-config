#!/usr/bin/env bash
# flake.lock を更新し、ISO 形式の日付を含むコミットを作成する。
#
# 使い方: update-flake-lock [input...]
#   input  更新する flake input。省略時はすべての input を更新する
set -euo pipefail

repo="$(git rev-parse --show-toplevel)"

if ! git -C "$repo" diff-index --quiet HEAD --; then
  printf 'Working tree has tracked changes; aborting.\n' >&2
  exit 1
fi

(
  cd "$repo"
  nix flake update "$@"
)

if git -C "$repo" diff-index --quiet HEAD -- flake.lock; then
  printf 'flake.lock is unchanged; nothing to commit.\n'
  exit 0
fi

git -C "$repo" commit flake.lock -m "Update flake.lock $(date +%F)"
