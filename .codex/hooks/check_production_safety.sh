#!/usr/bin/env bash
# Hook: check_production_safety.sh
# Targets:
#   - SECURITY: socket.dart MyHttpOverrides bypasses TLS globally
#   - CRASH RISK: print() in production paths (Room.fromJson, chat_connection.dart, socket.dart)
#   - BUG: headers.addAll(headers) self-referential no-op in http_connection.dart

REPO_ROOT="$(git -C "$(dirname "$0")/../.." rev-parse --show-toplevel 2>/dev/null || echo "/Users/mwang/WAO/Chat/chat_matthew")"
ERRORS=0

echo "=== Production Safety Check ==="

# 1. Detect unguarded print() in production files
# Checks lib/ recursively, excludes test/, excludes lines inside 'if (kDebugMode)' blocks
PRINT_FILES=$(grep -rn "print(" "$REPO_ROOT/lib" \
  --include="*.dart" \
  -l 2>/dev/null)

if [ -n "$PRINT_FILES" ]; then
  echo ""
  echo "[WARN] Unguarded print() calls found (must be wrapped in kDebugMode guard):"
  while IFS= read -r file; do
    # Show only lines with print( that are NOT preceded by kDebugMode on the same or immediately prior line
    grep -n "print(" "$file" | grep -v "kDebugMode" | while IFS= read -r line; do
      echo "  $file:$line"
    done
  done <<< "$PRINT_FILES"
  echo "  Known offenders per analysis: lib/data_model/room.dart:20, lib/connection/chat_connection.dart:282, lib/connection/socket.dart"
  ERRORS=$((ERRORS + 1))
fi

# 2. Detect MyHttpOverrides / badCertificateCallback always-true
SSL_BYPASS=$(grep -rn "badCertificateCallback.*true\|return true" "$REPO_ROOT/lib/connection/socket.dart" 2>/dev/null)
if [ -n "$SSL_BYPASS" ]; then
  echo ""
  echo "[ERROR] SSL bypass detected in lib/connection/socket.dart:"
  echo "  MyHttpOverrides.badCertificateCallback returns true unconditionally."
  echo "  This is applied via HttpOverrides.global on every init()/token() call."
  echo "  Must be conditioned on kDebugMode before production release."
  grep -n "badCertificateCallback\|HttpOverrides.global\|return true" "$REPO_ROOT/lib/connection/socket.dart" | head -10 | while IFS= read -r line; do
    echo "  socket.dart:$line"
  done
  ERRORS=$((ERRORS + 1))
fi

# 3. Detect self-referential headers.addAll(headers) (the known bug in http_connection.dart:76)
SELF_ADDALL=$(grep -rn "\.addAll(headers)" "$REPO_ROOT/lib/connection/http_connection.dart" 2>/dev/null | grep "headers\.addAll(headers)")
if [ -n "$SELF_ADDALL" ]; then
  echo ""
  echo "[ERROR] Self-referential addAll bug detected in lib/connection/http_connection.dart:"
  echo "  'headers.addAll(headers)' merges a Map into itself -- this is a no-op."
  echo "  The parameter is named 'header' (singular). Fix: headers.addAll(header)"
  echo "  Impact: brand-code header is silently dropped on checkUserToken calls."
  echo "$SELF_ADDALL" | while IFS= read -r line; do
    echo "  http_connection.dart:$line"
  done
  ERRORS=$((ERRORS + 1))
fi

# 4. Detect any new .addAll(headers) pattern elsewhere that might replicate the bug
NEW_SELF_ADDALL=$(grep -rn "\.addAll(headers)" "$REPO_ROOT/lib" --include="*.dart" 2>/dev/null \
  | grep "headers\.addAll(headers)")
if [ -n "$NEW_SELF_ADDALL" ]; then
  echo ""
  echo "[ERROR] Additional self-referential addAll(headers) found:"
  echo "$NEW_SELF_ADDALL" | while IFS= read -r line; do
    echo "  $line"
  done
  ERRORS=$((ERRORS + 1))
fi

echo ""
if [ "$ERRORS" -eq 0 ]; then
  echo "[OK] Production safety checks passed."
else
  echo "[FAIL] $ERRORS production safety issue(s) found. Address before release."
fi

exit 0
