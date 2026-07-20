# Workflow: Bug Fix — $ARGUMENTS

Quy trình fix bug có hệ thống, từ reproduce đến verify.

## Bước 1: Hiểu bug
1. Đọc bug description: `$ARGUMENTS`
2. Xác định:
   - Reproduce steps
   - Expected vs Actual behavior
   - Affected versions/devices
   - Stack trace (nếu có)

## Bước 2: Reproduce
1. Tìm code path liên quan qua stack trace hoặc feature flow
2. Đọc code để hiểu root cause (không đoán)
3. Viết failing test TRƯỚC khi fix:
   ```dart
   test('should NOT crash when X happens', () {
     // Reproduce bug scenario
     expect(() => sut.doThing(), returnsNormally);
   });
   ```
   Test này PHẢI fail với code hiện tại.

## Bước 3: Fix
1. Implement fix tối thiểu — không refactor thêm
2. Chạy test vừa viết → phải pass
3. Chạy toàn bộ test suite → không có regression

## Bước 4: Verify
```bash
dart analyze         # Zero new warnings
flutter test         # All tests pass
dart format lib/     # Code được format
```

## Bước 5: Commit
```
🐛 fix: <mô tả bug đã fix>

Root cause: <giải thích ngắn>
Fixes: #<issue number nếu có>
```

## Quy tắc
- Một PR = một bug fix
- Luôn có test reproduce trước khi fix
- Không fix nhiều bugs trong cùng một commit
