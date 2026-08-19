#!/usr/bin/env bash
set -euo pipefail

SOURCE_ROOT="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/arisc-platform.sh
source "$SOURCE_ROOT/lib/arisc-platform.sh"

TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

mkdir -p "$TEST_ROOT/reports" "$TEST_ROOT/project/.git" "$TEST_ROOT/project/src/deep"
printf 'old\n' > "$TEST_ROOT/reports/aris-report-old.md"
printf 'newer content\n' > "$TEST_ROOT/reports/aris-report-new.md"
touch -t 202001010000 "$TEST_ROOT/reports/aris-report-old.md"
touch -t 202101010000 "$TEST_ROOT/reports/aris-report-new.md"

mapfile -t ordered < <(arisc_files_by_mtime "$TEST_ROOT/reports" 'aris-report-*.md')
[[ "${#ordered[@]}" -eq 2 ]]
[[ "${ordered[0]}" == "$TEST_ROOT/reports/aris-report-new.md" ]]
[[ "$(arisc_stat_size "$TEST_ROOT/reports/aris-report-new.md")" -gt 0 ]]

printf 'tracked\n' > "$TEST_ROOT/project/src/deep/result.txt"
printf 'ignored\n' > "$TEST_ROOT/project/.git/index"
touch -t 202201010000 "$TEST_ROOT/project/src/deep/result.txt"
touch -t 202401010000 "$TEST_ROOT/project/.git/index"
latest="$(arisc_latest_mtime_depth "$TEST_ROOT/project" 3)"
[[ "$latest" == "$(arisc_stat_mtime "$TEST_ROOT/project/src/deep/result.txt")" ]]

ln -s "$TEST_ROOT/reports/aris-report-new.md" "$TEST_ROOT/latest.md"
[[ "$(arisc_realpath "$TEST_ROOT/latest.md")" == "$TEST_ROOT/reports/aris-report-new.md" ]]
[[ -n "$(arisc_date_from_epoch "$latest" '%Y-%m-%d')" ]]

arisc_run_with_timeout 2 true

if perl -ne '
  if (/(?<!\\)\$[A-Za-z_][A-Za-z0-9_]*[^\x00-\x7F]/) {
    print "$ARGV:$.:$_";
    $bad = 1;
  }
  END { exit($bad ? 1 : 0) }
' "$SOURCE_ROOT/install.sh" "$SOURCE_ROOT"/bin/* "$SOURCE_ROOT"/lib/*.sh "$SOURCE_ROOT"/tests/*.sh; then
  :
else
  echo "[ERROR] unbraced shell variable touches a non-ASCII character" >&2
  exit 1
fi

echo "[OK] GNU/BSD platform helper contract passed"
