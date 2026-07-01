#!/usr/bin/env bash
# Hook: detect hardcoded production URLs/credentials and socket listener leaks
# Targets real issues found in this repo:
#   - Hardcoded prod URLs + API key '62da77474991df7aa711a632' in http_connection.dart:11-14
#   - SSL bypass (MyHttpOverrides badCertificateCallback always true) in socket.dart
#   - socket.on() registered without socket.off() — stacking duplicate 'message-in' listeners
#     each time listenChat() is called on room load

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "/Users/mwang/WAO/Epoints/chat")"
LIB="$REPO_ROOT/lib"

# Files allowed to contain epoints.vn URLs (the canonical config locations)
ALLOWED_URL_FILES=(
  "lib/connection/http_connection.dart"
  "lib/common/constant.dart"
)

ERRORS=0

# ── 1. Hardcoded epoints.vn production URLs outside config files ─────────────
URL_HITS=$(grep -rn --include="*.dart" \
  -E "https?://[a-z.]*epoints\.vn" "$LIB" \
  || true)

FILTERED_URL_HITS=""
while IFS= read -r line; do
  FILE_PATH="${line%%:*}"
  # Make relative for comparison
  REL="${FILE_PATH#$REPO_ROOT/}"
  IS_ALLOWED=false
  for allowed in "${ALLOWED_URL_FILES[@]}"; do
    if [[ "$REL" == "$allowed" ]]; then
      IS_ALLOWED=true
      break
    fi
  done
  if [[ "$IS_ALLOWED" == false ]]; then
    FILTERED_URL_HITS="${FILTERED_URL_HITS}${line}"$'\n'
  fi
done <<< "$URL_HITS"

if [[ -n "${FILTERED_URL_HITS// }" ]]; then
  echo ""
  echo "ERROR: Hardcoded epoints.vn production URL found outside config/constant files."
  echo "       All URLs must live in http_connection.dart or common/constant.dart."
  echo "       Offending lines:"
  echo ""
  echo "$FILTERED_URL_HITS" | while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    echo "  $line"
  done
  echo ""
  ERRORS=$((ERRORS + 1))
fi

# ── 2. Hardcoded API key literal ─────────────────────────────────────────────
# The known committed credential is '62da77474991df7aa711a632'
APIKEY_HITS=$(grep -rn --include="*.dart" \
  -E "62da77474991df7aa711a632" "$LIB" \
  || true)

if [[ -n "$APIKEY_HITS" ]]; then
  echo ""
  echo "ERROR: Hardcoded API key '62da77474991df7aa711a632' detected in source."
  echo "       This credential must not be committed. Move it to a runtime config or env injection."
  echo ""
  echo "$APIKEY_HITS" | while IFS= read -r line; do
    echo "  $line"
  done
  echo ""
  ERRORS=$((ERRORS + 1))
fi

# ── 3. SSL bypass — badCertificateCallback always returning true ──────────────
SSL_HITS=$(grep -rn --include="*.dart" \
  -E "badCertificateCallback\s*=\s*\([^)]*\)\s*(=>|{)\s*(return\s+)?true" "$LIB" \
  || true)

if [[ -n "$SSL_HITS" ]]; then
  echo ""
  echo "ERROR: SSL bypass detected — badCertificateCallback always returns true."
  echo "       This disables TLS validation for the ENTIRE app process via HttpOverrides.global."
  echo "       Found in socket.dart (MyHttpOverrides). Remove or gate behind a debug flag."
  echo ""
  echo "$SSL_HITS" | while IFS= read -r line; do
    echo "  $line"
  done
  echo ""
  ERRORS=$((ERRORS + 1))
fi

# ── 4. socket.on() without socket.off() in same file ────────────────────────
# Specifically targets the 'message-in' duplicate-listener pattern in socket.dart listenChat().
# This is a heuristic: if a file has socket.on( but no socket.off( (or .off() call), warn.
SOCKET_ON_FILES=$(grep -rl --include="*.dart" \
  -E "\.on\s*\(" "$LIB" \
  || true)

while IFS= read -r filepath; do
  [[ -z "$filepath" ]] && continue
  ON_COUNT=$(grep -cE "\.on\s*\(" "$filepath" || true)
  OFF_COUNT=$(grep -cE "\.(off|clearListeners)\s*\(" "$filepath" || true)
  if [[ "$ON_COUNT" -gt 0 && "$OFF_COUNT" -eq 0 ]]; then
    echo ""
    echo "WARNING: $filepath registers $ON_COUNT socket.on() listener(s) but has no socket.off() call."
    echo "         Calling listenChat() repeatedly (e.g. on _refreshMessage) stacks duplicate listeners."
    echo "         Add socket.off('message-in') before re-registering in socket.dart."
    echo ""
    # Warning only — do not block
  fi
done <<< "$SOCKET_ON_FILES"

if [[ $ERRORS -gt 0 ]]; then
  echo "Pre-commit security check failed with $ERRORS error(s). Fix the issues above before committing."
  exit 1
fi

echo "pre-commit-security-and-sockets: OK"
exit 0
