#!/usr/bin/env bash
# Fail when this satellite grows a GitHub Pages workflow again.
# The live site is the hub copy. This file must stay absent.
set -euo pipefail

if [[ $# -ge 1 ]]; then
  root=$1
else
  root=$(cd "$(dirname "$0")/.." && pwd)
fi

target="$root/.github/workflows/pages.yml"
if [[ -e "$target" ]]; then
  printf 'fail: %s exists\n' "$target" >&2
  exit 1
fi

printf 'ok: .github/workflows/pages.yml is absent\n'
