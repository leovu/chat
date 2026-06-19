# Flutter Code Review Skill

Review toàn diện Flutter codebase theo các tiêu chí bên dưới.
Đánh giá mỗi hạng mục từ 1–10 với lý do cụ thể.

---

## 1. Code Quality (1–10)
- Naming conventions (snake_case files, PascalCase classes)
- Không có dead code, unused imports
- Không có `print()` trong production
- `const` được dùng đúng chỗ

## 2. Architecture (1–10)
- Clean Architecture / Feature-first được tuân thủ
- Separation of concerns: UI ↔ Logic ↔ Data
- Dependency injection nhất quán
- Repository pattern đúng chuẩn

## 3. State Management (1–10)
- BLoC/Cubit/Provider được dùng nhất quán
- States cover đủ: initial, loading, success, error
- Không có business logic trong Widget
- Streams được dispose đúng

## 4. Performance (1–10)
- `ListView.builder` cho danh sách
- Image caching (cached_network_image)
- Không có unnecessary setState
- Heavy operations trong isolates

## 5. Security (1–10)
- Không hardcode API keys/secrets
- flutter_secure_storage cho sensitive data
- Certificate pinning (nếu cần)
- Input validation

## 6. Test Coverage (1–10)
- Unit tests cho use cases, cubits
- Widget tests cho màn hình chính
- Mock bằng mocktail/mockito đúng cách
- Test naming rõ ràng: `should_doX_when_Y`

## Claude Code Checklist
- [ ] Hooks được cấu hình trong .claude/settings.json
- [ ] dart-format.sh chạy sau mỗi lần edit
- [ ] flutter-analyze.sh phát hiện lỗi sớm
- [ ] flutter-test.sh chạy khi sửa test files
- [ ] CLAUDE.md có đủ context cho dự án

## Output Format
Đưa ra:
1. Điểm từng hạng mục
2. Top 3 vấn đề cần sửa ngay
3. Top 3 điểm tốt cần duy trì
4. Recommendation: Excellent / Good / Needs Work / Refactor Required
