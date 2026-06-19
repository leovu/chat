# Workflow: Feature Complete — $ARGUMENTS

Vòng lặp đầy đủ: từ requirement đến PR sẵn sàng merge.

## Giai đoạn 1: Phân tích (5 phút)
1. Đọc `docs/architecture.md` và `CLAUDE.md`
2. Xác định các layers bị ảnh hưởng
3. List files cần tạo mới / sửa
4. Xác định API endpoints cần (tham khảo `docs/api.md`)
5. Trình bày plan → chờ confirm trước khi code

## Giai đoạn 2: Data Layer
Thứ tự: Model → DataSource → Repository → UseCase
```
lib/
  data/models/<feature>_model.dart
  data/data_sources/<feature>_remote_data_source.dart
  data/repositories/<feature>_repository_impl.dart
  domain/repositories/<feature>_repository.dart
  domain/use_cases/<feature>_use_case.dart
```
Sau mỗi file: `dart analyze`

## Giai đoạn 3: State Management
```
lib/features/<feature>/
  bloc/<feature>_cubit.dart
  bloc/<feature>_state.dart
```
Viết unit test ngay sau khi tạo Cubit.

## Giai đoạn 4: UI
```
lib/features/<feature>/
  presentation/pages/<feature>_page.dart
  presentation/widgets/<widget>.dart
```
Widget nhỏ, tách file riêng.

## Giai đoạn 5: Tests
```bash
flutter test test/features/<feature>/   # Run feature tests
flutter test                             # Full suite
```
Coverage target: ≥ 80% business logic.

## Giai đoạn 6: Cleanup & Commit
```bash
dart format lib/ test/
dart analyze
# /commit  ← chạy để tạo commit
```

## Checklist trước khi báo "Done"
- [ ] Tests pass (flutter test)
- [ ] Zero analyzer warnings
- [ ] Code được format
- [ ] `docs/api.md` cập nhật nếu có endpoint mới
- [ ] Feature hoạt động trên cả Android và iOS path logic
