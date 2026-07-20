#!/usr/bin/env bash
# Hook: check_localization.sh
# Targets:
#   - BUG: http_connection.dart:216 -- Vietnamese error string hardcoded in HTTP layer
#   - BUG: download.dart -- English SnackBar strings hardcoded bypassing AppLocalizations
#   - BUG: chat_connection.dart:813 -- Vietnamese content hardcoded in messageSystem() payload
# Pattern: All user-visible strings must use AppLocalizations.text(LangKey.xxx)

REPO_ROOT="$(git -C "$(dirname "$0")/../.." rev-parse --show-toplevel 2>/dev/null || echo "/Users/mwang/WAO/Chat/chat_matthew")"
ERRORS=0

echo "=== Localization Enforcement Check ==="

# Files in connection/ and download layers that must NOT contain raw user-visible strings
SCOPED_FILES=(
  "$REPO_ROOT/lib/connection/http_connection.dart"
  "$REPO_ROOT/lib/connection/chat_connection.dart"
  "$REPO_ROOT/lib/connection/download.dart"
  "$REPO_ROOT/lib/connection/socket.dart"
)

# 1. Check known offender files for hardcoded Vietnamese/English user-visible strings
# Pattern: string literals containing spaces (likely user-visible) that are NOT LangKey references
echo ""
echo "Checking connection/download layer for hardcoded user-visible strings..."

for FILE in "${SCOPED_FILES[@]}"; do
  if [ ! -f "$FILE" ]; then
    continue
  fi
  BASENAME=$(basename "$FILE")
  # Find quoted string literals with spaces (user-visible text) that are not LangKey/AppLocalizations
  HARDCODED=$(grep -n "'[A-Za-zÀ-ỹ][A-Za-zÀ-ỹ ]\{4,\}'" "$FILE" 2>/dev/null \
    | grep -v "LangKey\|AppLocalizations\|api/\|v2\|v3\|http\|wss\|ws:\|//\|\.dart\|package:\|class \|import \|://\|Content-Type\|application/json\|multipart\|boundary\|Bearer \|Authorization\|brand-code\|User-Agent\|text/plain")
  if [ -n "$HARDCODED" ]; then
    echo "  [WARN] $BASENAME contains hardcoded user-visible strings:"
    echo "$HARDCODED" | while IFS= read -r line; do
      echo "    $BASENAME:$line"
    done
    ERRORS=$((ERRORS + 1))
  fi
done

# 2. Broad scan across all lib/ for obvious Vietnamese hardcoded strings (non-LangKey)
echo ""
echo "Scanning lib/ for hardcoded Vietnamese strings outside LangKey..."
VI_STRINGS=$(grep -rn \
  "'[A-Za-zÀ-ỹ]*[àáâãèéêìíòóôõùúýăđơưạặầẩẫậắẵẳặẹẽẻếềệỉịọộỗổồốớờởợụữựứừửặ][A-Za-zÀ-ỹ ]\{3,\}'" \
  "$REPO_ROOT/lib" --include="*.dart" 2>/dev/null \
  | grep -v "LangKey\|AppLocalizations\|//\|_test\|\.g\.dart" \
  | grep -v "lib/localization/" \
  | head -20)

if [ -n "$VI_STRINGS" ]; then
  echo "  [WARN] Potential hardcoded Vietnamese strings found (verify these use LangKey):"
  echo "$VI_STRINGS" | while IFS= read -r line; do
    echo "    $line"
  done
  echo "  Known offenders: http_connection.dart:216, chat_connection.dart:813, download.dart"
  ERRORS=$((ERRORS + 1))
fi

# 3. Check for SnackBar/Text widgets with raw string literals outside localization pattern
echo ""
echo "Checking for SnackBar content with hardcoded English strings..."
SNACKBAR_HARDCODED=$(grep -rn "SnackBar\|snackBar" "$REPO_ROOT/lib" --include="*.dart" -A 3 2>/dev/null \
  | grep "content:.*'[A-Z][a-z ]" \
  | grep -v "LangKey\|AppLocalizations" \
  | head -10)

if [ -n "$SNACKBAR_HARDCODED" ]; then
  echo "  [WARN] SnackBar with hardcoded English content:"
  echo "$SNACKBAR_HARDCODED" | while IFS= read -r line; do
    echo "    $line"
  done
  echo "  Known offender: lib/connection/download.dart ('Photo library access is not granted', etc.)"
  ERRORS=$((ERRORS + 1))
fi

echo ""
if [ "$ERRORS" -eq 0 ]; then
  echo "[OK] Localization checks passed."
else
  echo "[WARN] $ERRORS localization issue(s) found."
  echo "Pattern: Use AppLocalizations.text(LangKey.xxx) for all user-visible strings."
  echo "LangKey values are defined in lib/localization/lang_key.dart."
fi

exit 0
