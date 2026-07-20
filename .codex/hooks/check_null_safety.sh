#!/usr/bin/env bash
# Hook: check_null_safety.sh
# Targets:
#   - CRASH RISK: Force-unwrap chains on room!.oa_group_id!, room!.people! in chat_group_members_screen.dart
#   - CRASH RISK: chat.dart:141 response!.error force-unwrap on nullable RoomResponse
#   - BUG: notificationCount() in chat_connection.dart:215 assigns notiChatHubZalo twice, never writes notiChatHubZaloPersonal
#   - PATTERN: SharedPreferences.getInstance() called directly instead of Globals.prefs singleton

REPO_ROOT="$(git -C "$(dirname "$0")/../.." rev-parse --show-toplevel 2>/dev/null || echo "/Users/mwang/WAO/Chat/chat_matthew")"
ERRORS=0

echo "=== Null Safety & Data Integrity Check ==="

# 1. Detect dangerous force-unwrap chains (more than one ! on same expression)
echo ""
echo "Checking for force-unwrap chains (x!.y! patterns)..."
FORCE_CHAINS=$(grep -rn "\!\.\w\+!" "$REPO_ROOT/lib" --include="*.dart" 2>/dev/null \
  | grep -v "//\|test/" \
  | head -30)
if [ -n "$FORCE_CHAINS" ]; then
  echo "  [WARN] Force-unwrap chains detected (crash risk on null):"
  echo "$FORCE_CHAINS" | while IFS= read -r line; do
    echo "    $line"
  done
  echo "  Known offenders: chat_group_members_screen.dart lines 56,144,221,231,272,282 (room!.oa_group_id!, room!.people!)"
  echo "  Known offender: chat.dart:141 (response!.error on nullable RoomResponse)"
  ERRORS=$((ERRORS + 1))
fi

# 2. Detect double-assignment to same field (notificationCount bug pattern)
echo ""
echo "Checking notificationCount() for double-assignment bug..."
CHAT_CONN="$REPO_ROOT/lib/connection/chat_connection.dart"
if [ -f "$CHAT_CONN" ]; then
  # Find notificationCount method and check for repeated assignments to notiChatHubZalo
  METHOD_BODY=$(awk '/notificationCount\(\)/,/^  \}/' "$CHAT_CONN" 2>/dev/null | head -40)
  ZALO_ASSIGNS=$(echo "$METHOD_BODY" | grep -c "notiChatHubZalo\s*=")
  if [ "$ZALO_ASSIGNS" -gt 1 ]; then
    echo "  [ERROR] notificationCount() assigns to notiChatHubZalo $ZALO_ASSIGNS times (notiChatHubZaloPersonal is never written)."
    echo "  chat_connection.dart:215 -- 'notiChatHubZaloPersonal' field (line 69) is never set; zalo_personal count is lost."
    echo "  Fix: second assignment should be 'notiChatHubZaloPersonal = result.zalo_personal;'"
    ERRORS=$((ERRORS + 1))
  fi

  # Also check for the notiChatHubZaloPersonal field declaration vs usage
  PERSONAL_DECL=$(grep -n "notiChatHubZaloPersonal" "$CHAT_CONN" | wc -l | tr -d ' ')
  PERSONAL_ASSIGN=$(grep -n "notiChatHubZaloPersonal\s*=" "$CHAT_CONN" | wc -l | tr -d ' ')
  if [ "$PERSONAL_DECL" -gt 0 ] && [ "$PERSONAL_ASSIGN" -eq 0 ]; then
    echo "  [ERROR] 'notiChatHubZaloPersonal' is declared but never assigned in chat_connection.dart."
    ERRORS=$((ERRORS + 1))
  fi
fi

# 3. Detect SharedPreferences.getInstance() outside approved locations
echo ""
echo "Checking for raw SharedPreferences.getInstance() calls outside singleton pattern..."
PREFS_DIRECT=$(grep -rn "SharedPreferences\.getInstance()" "$REPO_ROOT/lib" --include="*.dart" 2>/dev/null \
  | grep -v "lib/common/config\.dart\|lib/common/shared_prefs/\|//")
if [ -n "$PREFS_DIRECT" ]; then
  echo "  [WARN] SharedPreferences.getInstance() called outside singleton setup:"
  echo "$PREFS_DIRECT" | while IFS= read -r line; do
    echo "    $line"
  done
  echo "  Fix: use Globals.prefs (set up in lib/common/config.dart) instead of calling getInstance() each time."
  echo "  Known offender: lib/draft.dart"
  ERRORS=$((ERRORS + 1))
fi

# 4. Detect empty or swallowed catch blocks
echo ""
echo "Checking for swallowed exceptions (empty catch blocks)..."
SWALLOWED=$(grep -rn "catch (_) {}" "$REPO_ROOT/lib" --include="*.dart" 2>/dev/null \
  | head -20)
SWALLOWED2=$(grep -rn -A 1 "} catch" "$REPO_ROOT/lib" --include="*.dart" 2>/dev/null \
  | grep -B 1 "^--$\|^\s*}\s*$" \
  | grep "} catch" \
  | head -10)

if [ -n "$SWALLOWED" ]; then
  echo "  [WARN] Empty catch(_){} blocks (exceptions silently swallowed):"
  echo "$SWALLOWED" | while IFS= read -r line; do
    echo "    $line"
  done
  ERRORS=$((ERRORS + 1))
fi

# 5. Check for the 'reppliedMessageId' typo in API payloads
echo ""
echo "Checking for known typo 'reppliedMessageId' in API payloads..."
TYPO=$(grep -rn "reppliedMessageId\|memeberUserIds\|chanelId" "$REPO_ROOT/lib" --include="*.dart" 2>/dev/null)
if [ -n "$TYPO" ]; then
  echo "  [WARN] Known typos found (proliferated into API payload keys -- do NOT fix without coordinating with backend):"
  echo "$TYPO" | while IFS= read -r line; do
    echo "    $line"
  done
  echo "  NOTE: 'reppliedMessageId' is misspelled but the JSON key 'replies' is correct; API calls are not broken."
  echo "  NOTE: 'memeberUserIds'/'chanelId' appear in acceptPendingInvite/rejectPendingInvite -- verify server key names before renaming."
fi

echo ""
if [ "$ERRORS" -eq 0 ]; then
  echo "[OK] Null safety & data integrity checks passed."
else
  echo "[WARN] $ERRORS issue(s) found."
fi

exit 0
