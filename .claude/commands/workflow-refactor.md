# Workflow: Refactor — $ARGUMENTS

Refactor có kiểm soát — không thay đổi behavior, chỉ cải thiện structure.

## Nguyên tắc bất biến
- Tests phải pass TRƯỚC và SAU refactor
- Không thêm feature mới trong refactor commit
- Mỗi bước nhỏ, commit riêng

## Bước 1: Đánh giá
1. Xác định scope: file/class/function cần refactor
2. Đảm bảo có test coverage (nếu chưa → chạy `/test-generator` trước)
3. Chạy tests baseline: `flutter test`

## Bước 2: Xác định mục tiêu
Chọn một hoặc nhiều:
- [ ] Extract widget quá lớn
- [ ] Move business logic ra khỏi Widget → Cubit
- [ ] Rename cho rõ nghĩa hơn
- [ ] Remove duplicate code → shared utility
- [ ] Simplify nested callbacks → named functions
- [ ] Convert StatefulWidget → HookWidget (nếu dùng flutter_hooks)
- [ ] Optimize imports

## Bước 3: Thực hiện (từng bước nhỏ)
Sau MỖI bước:
```bash
flutter test         # Must pass
dart analyze         # Must pass
```

## Bước 4: Commit
```
♻️ refactor: <mô tả ngắn thay đổi>
```
Không mix refactor với features/fixes.

## Dấu hiệu refactor xong
- [ ] Tests vẫn pass 100%
- [ ] Code dễ đọc hơn trước
- [ ] Không có technical debt mới
- [ ] File size hợp lý (< 300 lines/file thường là tốt)
