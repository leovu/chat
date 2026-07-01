#!/bin/bash
# PostToolUse hook: Auto-format Dart files after Write/Edit
# Registers in .claude/settings.json

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
  dart format "$FILE" 2>/dev/null
fi
exit 0
