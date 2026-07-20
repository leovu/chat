#!/usr/bin/env bash
# Hook: check_bloc_lifecycle.sh
# Targets:
#   - LEAK: ConversationBloc leaves notes and _summary BehaviorSubject open on dispose()
#   - PATTERN: Every BehaviorSubject field in a BaseBloc subclass must be closed in dispose()
#   - PATTERN: Every screen that creates a bloc in initState must call _bloc.dispose() in dispose()
#   - CRASH RISK: static late Function callbacks on ChatConnection never null-checked before call
#   - CRASH RISK: ResponseData 'late Map<String,dynamic> data' / 'late String message' accessed when isSuccess=false

REPO_ROOT="$(git -C "$(dirname "$0")/../.." rev-parse --show-toplevel 2>/dev/null || echo "/Users/mwang/WAO/Chat/chat_matthew")"
ERRORS=0

echo "=== BLoC Lifecycle & Stream Leak Check ==="

# 1. Find dart files in presentation/ and chat_screen/ that instantiate a bloc in initState
#    but may not call dispose() on it
echo ""
echo "Checking screens for missing _bloc.dispose() calls..."

BLOC_SCREENS=$(grep -rln "= .*Bloc()\|= .*bloc\b" "$REPO_ROOT/lib" --include="*.dart" 2>/dev/null \
  | grep -v "_bloc\.dart\|base_bloc\.dart")

for FILE in $BLOC_SCREENS; do
  BASENAME=$(basename "$FILE")
  HAS_BLOC_ASSIGN=$(grep -c "Bloc()\|= .*[Bb]loc\b" "$FILE" 2>/dev/null || echo 0)
  HAS_DISPOSE_CALL=$(grep -c "_bloc\.dispose()\|bloc\.dispose()" "$FILE" 2>/dev/null || echo 0)
  HAS_DISPOSE_METHOD=$(grep -c "void dispose()" "$FILE" 2>/dev/null || echo 0)

  if [ "$HAS_BLOC_ASSIGN" -gt 0 ] && [ "$HAS_DISPOSE_METHOD" -gt 0 ] && [ "$HAS_DISPOSE_CALL" -eq 0 ]; then
    echo "  [WARN] $BASENAME: bloc assigned but dispose() never calls _bloc.dispose()"
    echo "    File: $FILE"
    ERRORS=$((ERRORS + 1))
  fi
done

echo "  Known offender: ConversationInformationScreen -- no _bloc.dispose() found per analysis."

# 2. Find BehaviorSubject fields in bloc files and verify they appear in dispose()
echo ""
echo "Checking BehaviorSubject fields are closed in dispose()..."

BLOC_FILES=$(find "$REPO_ROOT/lib" -name "*bloc*.dart" -o -name "*_bloc.dart" 2>/dev/null | grep -v ".g.dart")

for FILE in $BLOC_FILES; do
  BASENAME=$(basename "$FILE")
  # Count BehaviorSubject declarations
  SUBJECTS=$(grep -c "BehaviorSubject<" "$FILE" 2>/dev/null || echo 0)
  if [ "$SUBJECTS" -eq 0 ]; then
    continue
  fi

  # Check that dispose() method exists
  HAS_DISPOSE=$(grep -c "void dispose()" "$FILE" 2>/dev/null || echo 0)
  if [ "$HAS_DISPOSE" -eq 0 ]; then
    echo "  [WARN] $BASENAME: has $SUBJECTS BehaviorSubject(s) but no dispose() method"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  # Get subject variable names and check if each is closed in dispose()
  SUBJECT_VARS=$(grep "BehaviorSubject<" "$FILE" | grep -oE "_[a-zA-Z]+" | head -20)
  DISPOSE_BLOCK=$(awk '/void dispose\(\)/,/^  \}/' "$FILE" 2>/dev/null)

  while IFS= read -r VAR; do
    [ -z "$VAR" ] && continue
    if ! echo "$DISPOSE_BLOCK" | grep -q "${VAR}\.close()"; then
      echo "  [WARN] $BASENAME: BehaviorSubject '$VAR' may not be closed in dispose()"
      echo "    File: $FILE"
      ERRORS=$((ERRORS + 1))
    fi
  done <<< "$SUBJECT_VARS"
done

echo "  Known offender: conversation_bloc.dart -- notes and _summary subjects not closed."

# 3. Check for 'static late ' fields in ChatConnection that could throw LateInitializationError
echo ""
echo "Checking ChatConnection static late fields..."
CHAT_CONN="$REPO_ROOT/lib/connection/chat_connection.dart"
if [ -f "$CHAT_CONN" ]; then
  LATE_STATIC=$(grep -n "static late " "$CHAT_CONN" 2>/dev/null)
  if [ -n "$LATE_STATIC" ]; then
    echo "  [INFO] Static late fields in ChatConnection (LateInitializationError risk if accessed before assignment):"
    echo "$LATE_STATIC" | while IFS= read -r line; do
      echo "    chat_connection.dart:$line"
    done
    echo "  Affected callbacks: homeScreenNotificationHandler, chatScreenNotificationHandler, refreshRoom, etc."
    echo "  These are assigned in screen initState -- if screen is popped before assignment, crash occurs."
  fi
fi

# 4. Check ResponseData for 'late' fields (LateInitializationError when isSuccess=false)
echo ""
echo "Checking ResponseData for unsafe late fields..."
RESPONSE_FILES=$(grep -rln "late.*data\|late.*message" "$REPO_ROOT/lib/data_model/response/" --include="*.dart" 2>/dev/null)
if [ -n "$RESPONSE_FILES" ]; then
  echo "  [WARN] ResponseData models with 'late' fields accessed when isSuccess=false:"
  for F in $RESPONSE_FILES; do
    grep -n "late " "$F" | while IFS= read -r line; do
      echo "    $(basename $F):$line"
    done
  done
  echo "  Fix: use nullable types (Map<String,dynamic>? data, String? message) instead of late."
fi

echo ""
if [ "$ERRORS" -eq 0 ]; then
  echo "[OK] BLoC lifecycle checks passed."
else
  echo "[WARN] $ERRORS BLoC lifecycle issue(s) found."
  echo "Pattern: BaseBloc.dispose() must close ALL BehaviorSubject fields."
  echo "Pattern: Every screen dispose() must call _bloc.dispose()."
fi

exit 0
