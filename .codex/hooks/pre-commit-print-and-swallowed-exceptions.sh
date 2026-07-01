#!/usr/bin/env bash
# Hook: detect active print() calls and swallowed catch blocks
# Targets real issues found in this repo:
#   - Active print() in chat.dart:159/180, download.dart:112, room.dart:107, parse_html.dart:112/270
#   - 124 catch (_) {} / catch (e) {} blocks that silently discard all exceptions

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "/Users/mwang/WAO/Epoints/chat")"
LIB="$REPO_ROOT/lib"

ERRORS=0

# ── 1. Active print() calls ──────────────────────────────────────────────────
# Allow debugPrint() and lines that are comments.
# Reject bare print( not preceded by 'debug'.
PRINT_HITS=$(grep -rn --include="*.dart" \
  -E "^\s*print\(" "$LIB" \
  | grep -v "//.*print(" \
  | grep -v "debugPrint(" \
  || true)

if [[ -n "$PRINT_HITS" ]]; then
  echo ""
  echo "ERROR: Active print() calls detected. Use debugPrint() or a structured logger."
  echo "       Production builds leak PII to logcat via these calls."
  echo ""
  echo "$PRINT_HITS" | while IFS= read -r line; do
    echo "  $line"
  done
  echo ""
  ERRORS=$((ERRORS + 1))
fi

# ── 2. Empty catch blocks (swallowed exceptions) ─────────────────────────────
# Matches:  catch (_) {}   catch (e) {}   catch (e, s) {}
# with optional whitespace inside the braces.
CATCH_HITS=$(grep -rn --include="*.dart" \
  -E "catch\s*\([^)]+\)\s*\{\s*\}" "$LIB" \
  | grep -v "//.*catch" \
  || true)

if [[ -n "$CATCH_HITS" ]]; then
  echo ""
  echo "ERROR: Empty catch blocks detected — exceptions are silently swallowed."
  echo "       Critical paths (joinRoom, _notificationHandler, loadMessages) have had this bug."
  echo "       Add at minimum: debugPrint('context: \$e'); or rethrow;"
  echo ""
  echo "$CATCH_HITS" | while IFS= read -r line; do
    echo "  $line"
  done
  echo ""
  ERRORS=$((ERRORS + 1))
fi

# ── 3. async void functions (fire-and-forget — errors unobservable) ──────────
# Targets: saveDraftInput, deleteDraftInput, openFile patterns in draft.dart / download.dart
ASYNC_VOID_HITS=$(grep -rn --include="*.dart" \
  -E "^\s*(Future<void>|void)\s+\w+\s*\([^)]*\)\s+async" "$LIB" \
  | grep -v "//.*async" \
  | grep -v "override" \
  | grep -v "_build\|_test\|setUp\|tearDown" \
  || true)

if [[ -n "$ASYNC_VOID_HITS" ]]; then
  echo ""
  echo "WARNING: async void functions detected — callers cannot await errors."
  echo "         Known bad actors: saveDraftInput, deleteDraftInput (draft.dart), openFile (download.dart)."
  echo "         Consider returning Future<void> so callers can catch exceptions."
  echo ""
  echo "$ASYNC_VOID_HITS" | while IFS= read -r line; do
    echo "  $line"
  done
  echo ""
  # Warning only — do not block commit for this one
fi

if [[ $ERRORS -gt 0 ]]; then
  echo "Pre-commit check failed with $ERRORS error(s). Fix the issues above before committing."
  exit 1
fi

echo "pre-commit-print-and-swallowed-exceptions: OK"
exit 0
