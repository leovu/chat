# Commit

Tạo commit theo conventional commit format cho Flutter project.

## Quy trình

1. Chạy pre-commit checks:
   - `dart format --output=none --set-exit-if-changed lib/` — kiểm tra format
   - `dart analyze` — kiểm tra linting
2. `git status` để xem files staged
3. Nếu chưa có gì staged → `git add` các file liên quan
4. `git diff --staged` để hiểu thay đổi
5. Phân tích xem có nên chia nhỏ thành nhiều commit không
6. Tạo commit message theo format: `<emoji> <type>: <mô tả ngắn>`

## Conventional Commit Types

| Emoji | Type | Dùng khi |
|-------|------|----------|
| ✨ | feat | Thêm feature mới |
| 🐛 | fix | Sửa bug |
| ♻️ | refactor | Tái cấu trúc code |
| 📝 | docs | Cập nhật tài liệu |
| ✅ | test | Thêm/sửa test |
| 💄 | style | Thay đổi UI/style |
| 🔧 | chore | Config, pubspec, tools |
| ⚡️ | perf | Cải thiện hiệu năng |
| 🚑️ | fix | Hotfix khẩn cấp |
| 🌐 | feat | Localization |
| 📱 | feat | Responsive/adaptive UI |
| 🏗️ | refactor | Thay đổi kiến trúc |

## Quy tắc

- Dòng đầu < 72 ký tự, dùng tiếng Anh hoặc tiếng Việt nhất quán
- Mỗi commit một mục đích duy nhất
- Không commit code chưa format hoặc có analyzer warnings
