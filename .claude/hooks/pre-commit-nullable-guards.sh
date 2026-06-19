#!/usr/bin/env bash
# Hook: detect force-unwrap on nullable async returns and stale BuildContext patterns
# Targets real issues found in this repo:
#   - chat.dart:142 response!.error — force-unwrap on nullable RoomResponse after await
#   - ChatConnection.buildContext stored as static field and used in async callbacks
#     after widget dispose (download.dart:119, contacts_screen.dart:114, room_list_screen.dart:218)
#   - ResponseData late fields (isSuccess, data, message) accessed without null/late guard

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "/Users/mwang/WAO/Epoints/chat")"
LIB="$REPO_ROOT/lib"

ERRORS=0

# ── 1. Force-unwrap on awaited nullable results ──────────────────────────────
# Pattern:  await someFunc(...)  then on next non-blank line  something!.field
# Simpler heuristic: find '!.' that follows a variable assigned from an await on the same
# or next line. We grep for the specific known-bad patterns first.
FORCE_UNWRAP_HITS=$(grep -rn --include="*.dart" \
  -E "(response|result|chat|room|data)\s*!\s*\." "$LIB" \
  | grep -v "//.*!" \
  || true)

if [[ -n "$FORCE_UNWRAP_HITS" ]]; then
  echo ""
  echo "WARNING: Force-unwrap ('!') on likely-nullable async return value detected."
  echo "         Known crash: chat.dart:142 'response!.error' crashes when getRoomByPhoneNumber returns null."
  echo "         Prefer: 'response?.error ?? defaultValue' or an explicit null check."
  echo ""
  echo "$FORCE_UNWRAP_HITS" | while IFS= read -r line; do
    echo "  $line"
  done
  echo ""
  # Warning for now — change to ERRORS+=1 to make it blocking
fi

# ── 2. ChatConnection.buildContext used in async gap ────────────────────────
# Detects any file (outside chat.dart where it is assigned) reading ChatConnection.buildContext
# in a method that also has 'await' or 'async' — the context may be stale.
BUILDCTX_HITS=$(grep -rn --include="*.dart" \
  "ChatConnection\.buildContext" "$LIB" \
  | grep -v "lib/chat.dart" \
  | grep -v "//.*buildContext" \
  || true)

if [[ -n "$BUILDCTX_HITS" ]]; then
  echo ""
  echo "WARNING: ChatConnection.buildContext accessed outside chat.dart."
  echo "         This static context is set once in Chat.open() and becomes stale after navigation."
  echo "         Known bad usages: download.dart:119, contacts_screen.dart:114, room_list_screen.dart:218."
  echo "         Pass BuildContext explicitly or check 'context.mounted' before use."
  echo ""
  echo "$BUILDCTX_HITS" | while IFS= read -r line; do
    echo "  $line"
  done
  echo ""
  # Warning only — the field already exists; blocking would break existing code immediately
fi

# ── 3. Detect new 'static late' field declarations on ChatConnection ─────────
# Existing late fields are known; new ones added without guards are risky.
STATIC_LATE_HITS=$(grep -rn --include="*.dart" \
  -E "^\s*static\s+late\s+" "$LIB/connection/chat_connection.dart" \
  || true)

NEW_LATE_COUNT=$(echo "$STATIC_LATE_HITS" | grep -c "static late" || true)
# Known count from analysis is ~9 fields. Warn only if a new one appears.
KNOWN_LATE_COUNT=9
if [[ "$NEW_LATE_COUNT" -gt "$KNOWN_LATE_COUNT" ]]; then
  echo ""
  echo "WARNING: New 'static late' field(s) added to ChatConnection (found $NEW_LATE_COUNT, baseline $KNOWN_LATE_COUNT)."
  echo "         Accessing uninitialized 'static late' fields throws LateInitializationError with no user message."
  echo "         Add an initialized default or use '?' nullable type instead."
  echo ""
  echo "$STATIC_LATE_HITS" | while IFS= read -r line; do
    echo "  $line"
  done
  echo ""
fi

if [[ $ERRORS -gt 0 ]]; then
  echo "Pre-commit nullable-guard check failed with $ERRORS error(s). Fix the issues above before committing."
  exit 1
fi

echo "pre-commit-nullable-guards: OK"
exit 0
