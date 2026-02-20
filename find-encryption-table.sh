#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# Script: find-encryption-table.sh
#
# Output columns:
#     NAMESPACE  TIME  ENCRYPTION
#
# Usage:
#   ./find-encryption-table.sh <subjectRef> [k10-namespace] [tail-lines] [mode]
#
# mode:
#   all     -> show all matches (default)
#   latest  -> show only the latest match (based on timestamp string)
# ------------------------------------------------------------

TARGET_NS="${1:-}"
K10_NS="${2:-kasten-io}"
TAIL_LINES="${3:-300000}"
MODE="${4:-all}"

if [[ -z "$TARGET_NS" ]]; then
  echo "ERROR: missing SubjectRef (workload namespace)."
  echo "Usage: $0 <subjectRef> [k10-namespace] [tail-lines] [all|latest]"
  exit 1
fi

# Print header
printf "%-20s %-35s %s\n" "NAMESPACE" "TIME" "ENCRYPTION"
printf "%-20s %-35s %s\n" "---------" "----" "----------"

# Gather logs from all executor pods (current + previous), parse fields, filter and format
rows="$(
  for p in $(kubectl -n "$K10_NS" get pods -o name | grep executor); do
    kubectl -n "$K10_NS" logs "$p" --all-containers --tail="$TAIL_LINES" 2>/dev/null || true
    kubectl -n "$K10_NS" logs -p "$p" --all-containers --tail="$TAIL_LINES" 2>/dev/null || true
  done \
  | awk '
      {
        ns=""; t=""; enc="";

        # SubjectRef
        if (match($0, /"SubjectRef":"([^"]+)"/, m)) ns=m[1];

        # Timestamp
        if (match($0, /"time":"([^"]+)"/, mt)) t=mt[1];

        # Encryption is inside escaped JSON: \"encryption\":\"...\"
        if (match($0, /\\"encryption\\":\\"([^\\"]+)\\"/, me)) enc=me[1];

        if (ns != "" && t != "" && enc != "")
          print ns "\t" t "\t" enc;
      }
    ' \
  | awk -v target="$TARGET_NS" -F'\t' '$1==target {print}'
)"

if [[ -z "$rows" ]]; then
  echo "(no matches found for SubjectRef=$TARGET_NS in last $TAIL_LINES lines across executor pods)"
  exit 0
fi

if [[ "$MODE" == "latest" ]]; then
  # Sort by time (lexicographic works for RFC3339-like timestamps) and keep the last
  rows="$(echo "$rows" | sort -t $'\t' -k2,2 | tail -n 1)"
fi

# Print formatted rows
echo "$rows" | awk -F'\t' '{ printf "%-20s %-35s %s\n", $1, $2, $3 }'