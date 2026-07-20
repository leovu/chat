#!/bin/bash
# PostToolUse hook: Run flutter analyze on modified Dart files
# Chỉ chạy analyze trên file vừa edit, không analyze toàn project (quá chậm)

INPUT=$(cat)
FILE=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('file_path', ''))
except:
    print('')
" 2>/dev/null)

if [[ "$FILE" == *.dart ]]; then
  ROOT=$(git -C "$(dirname "$FILE")" rev-parse --show-toplevel 2>/dev/null || dirname "$FILE")
  cd "$ROOT"
  RESULT=$(dart analyze "$FILE" 2>&1)
  EXIT_CODE=$?
  if [ $EXIT_CODE -ne 0 ]; then
    echo "$RESULT"
    exit 2
  fi
fi
exit 0
