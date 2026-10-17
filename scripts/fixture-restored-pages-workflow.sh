#!/usr/bin/env bash
# HEAD must pass because pages.yml is deleted.
# A temp tree that restores the historical file must fail the same check.
# The restored file is never written into this repository.
set -euo pipefail

repo=$(cd "$(dirname "$0")/.." && pwd)
check="$repo/scripts/check-no-pages-workflow.sh"
blob_ref="32f7f032a6596a8b12544954669ea4110389cbcd:.github/workflows/pages.yml"
live="$repo/.github/workflows/pages.yml"

set +e
bash "$check" "$repo"
head_status=$?
set -e
printf 'HEAD exit %s\n' "$head_status"
if [[ "$head_status" -ne 0 ]]; then
  exit 1
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/.github/workflows"
git -C "$repo" show "$blob_ref" > "$tmp/.github/workflows/pages.yml"
git -C "$repo" show "$blob_ref" | cmp - "$tmp/.github/workflows/pages.yml"

set +e
bash "$check" "$tmp"
fixture_status=$?
set -e
printf 'fixture exit %s\n' "$fixture_status"
if [[ "$fixture_status" -ne 1 ]]; then
  printf 'expected restored pages.yml to fail with exit 1\n' >&2
  exit 1
fi

if [[ -e "$live" ]]; then
  printf 'fixture wrote pages.yml into the repository\n' >&2
  exit 1
fi
