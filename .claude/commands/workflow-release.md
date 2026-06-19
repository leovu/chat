# Workflow: Release $ARGUMENTS

Quy trình release đầy đủ — từ version bump đến build artifact.

## Bước 1: Pre-release Checks
```bash
flutter test                              # Toàn bộ tests phải pass
dart analyze                              # Zero warnings
dart format --output=none --set-exit-if-changed lib/
```
Nếu có lỗi → DỪNG, báo cáo cho user.

## Bước 2: Version Bump
1. Đọc version hiện tại trong `pubspec.yaml` (format: `major.minor.patch+build`)
2. Xác định loại release:
   - `patch`: bug fix → tăng patch (1.2.3 → 1.2.4)
   - `minor`: feature mới → tăng minor (1.2.3 → 1.3.0)
   - `major`: breaking change → tăng major (1.2.3 → 2.0.0)
3. Cập nhật `pubspec.yaml`
4. Tăng build number (+1)

## Bước 3: Changelog
1. `git log <previous_tag>..HEAD --oneline` để lấy commits
2. Tạo/cập nhật `CHANGELOG.md`:
   ```markdown
   ## [1.2.4] - 2026-06-19
   ### Fixed
   - ...
   ### Added
   - ...
   ```

## Bước 4: Commit & Tag
```bash
git add pubspec.yaml CHANGELOG.md
git commit -m "🔖 chore: release v<version>"
git tag -a v<version> -m "Release v<version>"
```

## Bước 5: Build
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS (nếu applicable)
flutter build ipa --release
```

## Bước 6: Báo cáo
Tóm tắt:
- Version: old → new
- Build artifacts tạo tại đâu
- Những thay đổi trong release này
