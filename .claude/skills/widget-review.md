# Widget Review Skill

Phân tích và review Flutter widgets theo chiều sâu.

## Checklist

### Composition
- [ ] Widget có quá nhiều responsibilities không? (Single Responsibility)
- [ ] Có thể tách thành các widget nhỏ hơn không?
- [ ] Stateless hay Stateful đúng chỗ?
- [ ] `const` constructor ở những widget không thay đổi

### Build Performance
- [ ] `build()` có expensive operations không? (vòng lặp, tính toán phức tạp)
- [ ] Dùng `RepaintBoundary` cho animations nặng
- [ ] `IndexedStack` vs `Visibility` vs điều kiện render
- [ ] `AutomaticKeepAliveClientMixin` cho tabs cần giữ state

### Layout
- [ ] Tránh `Column` trong `SingleChildScrollView` không có `shrinkWrap`
- [ ] Không dùng `Expanded` bên ngoài `Flex` widget
- [ ] `MediaQuery` được dùng đúng chỗ (không gọi trong loop)
- [ ] Overflow được xử lý (`Flexible`, `Expanded`, `FittedBox`)

### State & Lifecycle
- [ ] `initState` / `dispose` cân bằng (init → dispose)
- [ ] Không gọi `setState` sau `dispose`
- [ ] `StreamSubscription` được cancel trong `dispose`
- [ ] `AnimationController` được dispose

### Accessibility
- [ ] `Semantics` label cho icon-only buttons
- [ ] `Tooltip` cho actions không rõ ràng
- [ ] Minimum tap target 44×44px
- [ ] `excludeSemantics` cho decorative elements

## Output
Báo cáo theo format:
```
Widget: <tên widget>
Issues: [list]
Suggestions: [list]
Refactored snippet (nếu cần):
```
