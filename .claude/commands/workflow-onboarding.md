# Workflow: Onboarding — Khám phá dự án

Đọc và tổng hợp toàn bộ context dự án để Claude hiểu trước khi làm việc.

## Bước 1: Đọc tài liệu cốt lõi
1. Đọc `CLAUDE.md` — conventions và commands
2. Đọc `docs/architecture.md` — cấu trúc dự án
3. Đọc `docs/api.md` — API endpoints
4. Đọc `docs/ui-guidelines.md` — design system
5. Đọc `pubspec.yaml` — dependencies và version

## Bước 2: Khám phá codebase
```bash
# Cấu trúc thư mục
find lib/ -type d | head -30

# Packages đang dùng
cat pubspec.yaml | grep -A 50 "dependencies:"

# Số lượng files
find lib/ -name "*.dart" | wc -l
find test/ -name "*.dart" | wc -l 2>/dev/null || echo "0 test files"
```

## Bước 3: Hiểu state management
- Tìm pattern đang dùng: BLoC, Cubit, Provider, Riverpod, GetX
- Đọc 1–2 Cubit/BLoC example để hiểu convention

## Bước 4: Hiểu API layer
- Tìm Dio/http setup
- Đọc base repository hoặc base API service

## Bước 5: Báo cáo
Tóm tắt:
- Stack: Flutter version, state management, DI
- Architecture pattern: Feature-first / Layer-first
- Conventions quan trọng
- Files chính cần biết
- Điểm cần chú ý đặc biệt (technical debt, gotchas)
