# Feature: $ARGUMENTS

Tạo feature mới cho Flutter app theo cấu trúc chuẩn.

## Quy trình

1. **Đọc tài liệu** — Đọc `docs/architecture.md` và `CLAUDE.md` để hiểu cấu trúc dự án
2. **Phân tích yêu cầu** — Xác định:
   - Feature cần gì (UI, logic, API calls)
   - State management cần dùng (Cubit/BLoC)
   - Models/entities cần tạo
3. **Tạo cấu trúc thư mục**:
   ```
   lib/features/<feature_name>/
   ├── presentation/
   │   ├── pages/
   │   ├── widgets/
   │   └── bloc/ (hoặc cubit/)
   ├── domain/
   │   ├── entities/
   │   └── use_cases/
   └── data/
       ├── models/
       ├── repositories/
       └── data_sources/
   ```
4. **Implement theo thứ tự**: Model → Repository → UseCase → Cubit/BLoC → UI
5. **Viết test** cho business logic (use cases, cubits)
6. **Format và analyze**: `dart format lib/` && `dart analyze`
7. **Commit** với `/commit`
