# Architecture Conventions & Known Pitfalls

## What this skill covers
Repo-specific naming conventions, folder layout quirks, localization patterns, and a catalogue of known issues to avoid reintroducing. Use before adding any new file, class, or API call.

## Folder Layout (with quirks)

```
lib/
  chat.dart                     # Plugin entry point -- Chat.open() static method
  chat_web.dart                 # Web stub
  draft.dart                    # SharedPreferences helpers (should use Globals.prefs -- see below)
  chat_screen/                  # OLDER screens -- direct ChatConnection coupling (do not add to)
  chat_ui/                      # Forked flutter_chat_ui (do not upgrade dependency blindly)
  common/
    base_bloc.dart              # Custom BLoC base (NOT flutter_bloc)
    widges/                     # TYPO FOLDER -- mirrors common/widgets/ (do not create new files here)
    widgets/                    # Correct folder for new widgets
    shared_prefs/               # SharedPreferences singleton wrapper
    config.dart                 # Sets Globals.prefs on startup
    global.dart                 # Globals class (Globals.prefs etc.)
  connection/
    chat_connection.dart        # God object (~1270 lines) -- owns ALL API calls
    http_connection.dart        # dart:http wrapper (dio is declared in pubspec but unused)
    socket.dart                 # Socket.IO + MyHttpOverrides (SSL bypass)
    download.dart               # File download helpers (hardcoded English strings)
    app_lifecycle.dart          # AppLifeCycle mixin
  localization/
    lang_key.dart               # All LangKey.xxx enum/constants
    app_localizations.dart      # AppLocalizations.text(LangKey.xxx) -- always use this
    chat_en.json / chat_vi.json # (assets) string tables
  presentation/                 # NEWER screens -- BLoC pattern (add new screens here)
    chat_module/
    conversation_modules/
    note_modules/
    utils/
      ultility.dart             # TYPO in filename (do not rename -- it will break imports)
```

## Naming Conventions

### DO follow:
- Dart field names: `camelCase` (e.g., `roomAvatar`, `oaGroupId`)
- File names: `snake_case.dart`
- New widgets: place in `lib/common/widgets/` (NOT `widges/`)
- New screens: place in `lib/presentation/`

### KNOWN violations (DO NOT propagate):
| Wrong | Correct | Location |
|---|---|---|
| `room_avatar`, `oa_group_id` in Dart fields | `roomAvatar`, `oaGroupId` | data_model/room.dart |
| `reppliedMessageId` | `repliedMessageId` | chat_connection.dart params (API JSON key 'replies' is correct -- do NOT change JSON key) |
| `memeberUserIds` | `memberUserIds` | acceptPendingInvite, rejectPendingInvite, chat_group_member_bloc.dart |
| `chanelId` | `channelId` | same functions above |
| `widges/` folder | `widgets/` | lib/common/ |
| `ultility.dart` | `utility.dart` | lib/presentation/utils/ (DO NOT rename -- will break imports) |

## Localization Pattern

All user-visible strings MUST use:
```dart
AppLocalizations.text(LangKey.someKey)
```

LangKey constants are in `lib/localization/lang_key.dart`.
String values are in assets: `chat_en.json` (English) and `chat_vi.json` (Vietnamese).

### Prohibited -- strings hardcoded in connection/download layers:
- `lib/connection/http_connection.dart:216`: `'Loi khi xu ly phan hoi tu server.'` -- hardcoded Vietnamese
- `lib/connection/chat_connection.dart:813`: `'Da gui tin tuong tac: Tin danh gia'` -- hardcoded Vietnamese in API payload
- `lib/connection/download.dart`: `'Photo library access is not granted'`, `'File has been downloaded to the device'` -- hardcoded English SnackBar strings

### When adding a new user-visible string:
1. Add the key to `lib/localization/lang_key.dart`
2. Add the value to both `chat_en.json` and `chat_vi.json`
3. Use `AppLocalizations.text(LangKey.yourKey)` in the widget

## SharedPreferences: Use Singleton

```dart
// WRONG -- called raw on every save/get (pattern in draft.dart):
final prefs = await SharedPreferences.getInstance();
await prefs.setString('key', value);

// CORRECT -- use the singleton from Globals (set up in config.dart):
Globals.prefs.setString('key', value);
```

`Config` initializes `Globals.prefs` at startup. Any code outside `lib/common/config.dart` and `lib/common/shared_prefs/` that calls `SharedPreferences.getInstance()` is violating this pattern.

## HTTP Layer: dart:http NOT dio

Despite `dio: ^5.8.0+1` in `pubspec.yaml`, the actual HTTP layer in `lib/connection/http_connection.dart` uses the `dart:http` package directly. Do NOT add new API calls using `dio` -- use `HTTPConnection.post()`, `get()`, `upload()`, or `postReturnList()`.

## URL Construction Pattern

```dart
// Current pattern (inline ternary, no constants):
String version = ChatConnection.isChatHub ? '/v2' : '';
final response = await connection.post('api${version}/rooms/list', body);

// When adding a new endpoint that differs by isChatHub mode:
// 1. Add the isChatHub ternary inline (consistent with existing ~20 sites)
// 2. Do NOT introduce a new constants file without migrating existing sites
```

## Navigation: No Named Routes

All navigation uses:
```dart
Navigator.of(context, rootNavigator: true).push(
  MaterialPageRoute(builder: (_) => MyScreen()),
);
```
No `go_router`, no named routes. Do not introduce them for single screens -- keep the existing pattern.

## SSL Bypass: Production Risk

`lib/connection/socket.dart` contains:
```dart
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
```
Applied via `HttpOverrides.global = MyHttpOverrides();` in both `init()` and `token()`.

This bypasses ALL TLS certificate validation globally. It is a development scaffold that was NEVER conditioned on `kDebugMode` and NEVER removed for production builds.

Before any production release: wrap with `if (kDebugMode)` or remove entirely.

## AppLifecycle: iOS Spurious Disconnects

`lib/connection/app_lifecycle.dart` calls `ChatConnection.dispose()` on BOTH `AppLifecycleState.inactive` AND `AppLifecycleState.paused`.

On iOS, `inactive` fires whenever a system dialog appears (notification prompt, phone call overlay, etc.) -- this kills the socket unnecessarily.

Fix: only call `dispose()` on `paused` (background), not `inactive`.

## kDebugMode Guards for print()

Every `print()` statement must be wrapped:
```dart
if (kDebugMode) {
  print('debug info');
}
```

Known unguarded print() sites:
- `lib/data_model/room.dart:20` -- prints every room object in fromJson
- `lib/connection/chat_connection.dart:282` -- prints room ID in autoUpdateChatSeenWhenJoinRoom()
- `lib/connection/socket.dart` -- prints auth token status
