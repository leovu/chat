# Localization Skill

Thêm hoặc mở rộng i18n/l10n cho Flutter app.

## Setup (nếu chưa có)
```yaml
# pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

flutter:
  generate: true
```

```yaml
# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

## Quy trình thêm string mới

1. **Tìm hardcoded strings** trong codebase:
   ```bash
   grep -r "Text('" lib/ --include="*.dart" | grep -v "//.*Text"
   ```

2. **Thêm vào ARB file** (`lib/l10n/app_vi.arb`):
   ```json
   {
     "@@locale": "vi",
     "buttonLogin": "Đăng nhập",
     "@buttonLogin": { "description": "Login button text" },
     "greetingUser": "Xin chào, {name}!",
     "@greetingUser": {
       "placeholders": { "name": { "type": "String" } }
     }
   }
   ```

3. **Sử dụng trong widget**:
   ```dart
   Text(AppLocalizations.of(context)!.buttonLogin)
   Text(AppLocalizations.of(context)!.greetingUser(userName))
   ```

4. **Generate**: `flutter gen-l10n`

## Checklist
- [ ] Không có hardcoded string trong UI
- [ ] Tất cả ngôn ngữ có cùng keys
- [ ] RTL support nếu cần (Arabic, Hebrew)
- [ ] Number/Date formatting theo locale
- [ ] Plural rules đúng (`one`, `other`, `zero`)

## Output
- Cập nhật tất cả ARB files
- Replace hardcoded strings trong widgets
- Chạy `flutter gen-l10n` để verify
