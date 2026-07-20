#!/bin/bash
# PostToolUse hook: Run flutter test khi edit test files
# Chỉ trigger với files trong thư mục test/

INPUT=$(cat)
FILE=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('file_path', ''))
except:
    print('')
" 2>/dev/null)

if [[ "$FILE" == */test/*.dart ]] || [[ "$FILE" == *_test.dart ]]; then
  ROOT=$(git -C "$(dirname "$FILE")" rev-parse --show-toplevel 2>/dev/null || dirname "$FILE")
  cd "$ROOT"
  RESULT=$(flutter test "$FILE" 2>&1)
  EXIT_CODE=$?
  if [ $EXIT_CODE -ne 0 ]; then
    echo "$RESULT"
    exit 2
  fi
fi
exit 0
