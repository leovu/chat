# Performance Audit Skill

Phân tích hiệu năng Flutter app và đề xuất tối ưu cụ thể.

## Kiểm tra theo tầng

### UI Layer
- [ ] Đếm số lần `setState` trigger không cần thiết
- [ ] Widget rebuild tracking: dùng `debugPrintRebuildDirtyWidgets = true`
- [ ] `const` widget coverage — bao nhiêu % widgets dùng const?
- [ ] Image: dùng `cached_network_image`? Resize trước khi display?
- [ ] Animation: dùng `AnimatedBuilder` thay vì `setState`?
- [ ] List: `ListView.builder` / `SliverList` thay vì `Column`?

### State Management
- [ ] BLoC/Cubit scope quá rộng? (Provider ở quá cao trong tree)
- [ ] `BlocSelector` thay vì `BlocBuilder` cho partial state
- [ ] Stream không được close gây memory leak?
- [ ] `distinct()` operator trên streams?

### Data Layer
- [ ] N+1 query problem trong repository?
- [ ] Pagination implement chưa?
- [ ] Cache strategy: memory cache → disk cache → network
- [ ] Debounce cho search inputs (tránh gọi API liên tục)

### Network
- [ ] Request deduplication (cùng lúc 2 requests giống nhau)
- [ ] Response caching với `dio_cache_interceptor`
- [ ] Compression (gzip) được enable?
- [ ] Image lazy loading

### Build Size
- [ ] `flutter build apk --analyze-size` — xem breakdown
- [ ] Unused assets trong `pubspec.yaml`
- [ ] ProGuard/R8 rules đúng?
- [ ] Split APK theo ABI?

## Công cụ đo lường
```bash
flutter run --profile          # Profile mode
flutter run --trace-startup    # Startup time
flutter test --coverage        # Test coverage
flutter build apk --analyze-size
```

## Output
Liệt kê issues theo impact: 🔴 High / 🟡 Medium / 🟢 Low
Với code snippet tối ưu cụ thể cho từng issue.
