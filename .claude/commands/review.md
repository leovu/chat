# Review: $ARGUMENTS

Review code hoặc PR cho Flutter project. Thực hiện từng task theo thứ tự.

---

## Task 1: Dart/Flutter Code Quality

- Code có tuân theo `dart analyze` rules không?
- Naming conventions: `snake_case` cho files, `PascalCase` cho classes, `camelCase` cho variables
- Không có unused imports, variables, parameters
- Không có `print()` statements trong production code
- Widget tree có quá sâu không? (> 5 levels nên refactor)

## Task 2: Architecture Review

- Có vi phạm separation of concerns không? (UI không gọi API trực tiếp)
- Business logic có nằm trong widget không? (nên chuyển vào Cubit/BLoC)
- Repository pattern được tuân thủ không?
- Dependency injection được dùng đúng không?

## Task 3: State Management

- Cubit/BLoC states có cover đủ cases không? (initial, loading, success, error)
- Không có state mutation trực tiếp
- Stream subscription được dispose đúng không?
- `context.read()` vs `context.watch()` dùng đúng chỗ không?

## Task 4: Performance

- `const` constructors được dùng khi có thể
- `ListView.builder` thay vì `ListView` cho list dài
- Image caching được implement
- Không có unnecessary rebuilds (`setState` quá rộng)

## Task 5: Security

- API keys không hardcode trong code
- Sensitive data không log ra console
- Input validation ở UI layer
- Không dùng `http` package mà không verify SSL

## Task 6: Test Coverage

- Có unit tests cho business logic không?
- Widget tests cho UI critical paths
- Mock dependencies đúng cách

---

**Kết quả**: Liệt kê issues theo mức độ: 🔴 Critical / 🟡 Warning / 🟢 Suggestion
