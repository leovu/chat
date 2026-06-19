# Plugin Integration Guide & BLoC Patterns

## Plugin entry point

This is a **Flutter plugin**, not a standalone app. The public API is the `Chat` static class in `/lib/chat.dart`.

### Host app integration — required call sequence

```dart
// 1. Initialize SharedPreferences (must happen before Chat.open)
await Config.getPreferences();  // lib/common/config.dart

// 2. Open the chat plugin — pass all optional callbacks your host app supports
Chat.open(
  context,
  domain: 'https://your-domain.epoints.vn/',   // override static domain if needed
  token: userJwtToken,
  brandCode: 'YOUR_BRAND',
  locale: Locale('vi'),
  appIcon: 'assets/icon.png',

  // Optional extension callbacks — host app implements these
  searchProducts: (context, roomID) async { /* ... */ },
  createOrder:    (context, roomID) async { /* ... */ },
  addCustomer:    (context, roomID) async { /* ... */ },

  // Notification routing callbacks
  onHomeScreenNotification:  (payload) { /* route from home */ },
  onChatScreenNotification:  (payload) { /* route from chat */ },

  // Refresh callbacks — called by plugin when host data needs updating
  refreshRoom:          () { setState(() {}); },
  refreshContact:       () { setState(() {}); },
  refreshFavorites:     () { setState(() {}); },
  refreshNotifications: () { /* update badge */ },
);

// 3. Connect socket AFTER Chat.open sets all static fields
await Chat.connectSocket();
```

### Disconnect on app pause / dispose

`AppLifeCycle` (`/lib/connection/app_lifecycle.dart`) is a `WidgetsBindingObserver` mixin on the main chat view's `State`. It handles:
- `didChangeAppLifecycleState(AppLifecycleState.paused)` → `ChatConnection.disconnectSocket()`
- `didChangeAppLifecycleState(AppLifecycleState.resumed)` → `ChatConnection.connectSocket()`

Host apps do not need to manage socket lifecycle manually — only call `Chat.connectSocket()` on initial open.

### Push notification routing

```dart
// From home screen (no chat screen open)
Chat.openNotification(payload, context);  // uses homeScreenNotificationHandler

// From within chat screen
// chatScreenNotificationHandler is invoked by the plugin itself
```

`openNotification()` distinguishes handlers via `ChatConnection.homeScreenNotificationHandler` vs `chatScreenNotificationHandler` — both are set by `Chat.open()`.

### addOnModules extensibility

The `addOnModules` parameter on `Chat.open()` accepts a list of `ChatModule` objects. This is how the host app injects custom screens (e.g., product search, order creation) that appear as action buttons inside the chat input area.

---

## Two-layer architecture — which pattern to use

| Location | Pattern | When to use |
|---|---|---|
| `presentation/` | `BaseBloc` + `BehaviorSubject` + `StreamBuilder` | All new code |
| `chat_screen/` | `StatefulWidget` + `setState` | Maintenance only — do not add new features here |

### BaseBloc pattern (`/lib/common/base_bloc.dart`)

```dart
class MyBloc extends BaseBloc {
  final _data = BehaviorSubject<List<Room>>();
  Stream<List<Room>> get outputData => _data.stream;

  void loadData() async {
    // BaseBloc.set() guards against writing to a closed sink
    set(_data, await RoomService.getRooms());
  }

  @override
  void dispose() {
    _data.close();
    super.dispose();
  }
}
```

`BaseBloc.set(subject, value)` checks `!subject.isClosed` before adding — always use `set()` instead of `subject.add()` to avoid BadState on disposed blocs.

### StreamBuilder consumption (presentation/ pattern)

```dart
StreamBuilder<List<Room>>(
  stream: _bloc.outputData,
  builder: (context, snapshot) {
    if (!snapshot.hasData) return const CircularProgressIndicator();
    return RoomListWidget(rooms: snapshot.data!);
  },
)
```

Never use `snapshot.data!` without checking `snapshot.hasData` first — BehaviorSubject emits the last value synchronously but `hasData` is still the correct guard.

---

## Localization system

This repo uses a **custom l10n system**, NOT Flutter's intl/arb toolchain (despite `intl` being a dependency).

- String keys: `/lib/localization/lang_key.dart` — all keys are `static const String` constants
- Loader: `/lib/localization/app_localizations.dart` — loads JSON from assets at runtime
- JSON assets: `assets/lang/vi.json`, `assets/lang/en.json` (verify actual asset paths)

Usage:
```dart
AppLocalizations.of(context).translate(LangKey.someKey)
```

**Do not** use `Intl.message()` or `.arb` files — they are not wired up. Add new strings by:
1. Adding a `static const String newKey = 'new_key';` to `LangKey`
2. Adding `"new_key": "Translated text"` to each language JSON

---

## Draft persistence — use Globals.prefs, not fresh getInstance()

`draft.dart` at the repo root currently calls `SharedPreferences.getInstance()` on every read/write. This is wasteful. The correct pattern is:

```dart
// WRONG — creates a new Future on every call
final prefs = await SharedPreferences.getInstance();

// CORRECT — use the singleton already initialized by Config.getPreferences()
final prefs = Globals.prefs;  // lib/common/global.dart
```

`Globals.prefs` is guaranteed to be initialized after step 1 of the plugin call sequence. Use it directly without `await`.

---

## Known structural issues to avoid replicating

1. **Do not add fields to `ChatConnection`** — it is already a god object with ~25 static fields. Use a dedicated service class instead.
2. **Do not use `static late`** for new fields — initialize to a safe default or use nullable type.
3. **Do not register `socket.on()` without a paired `socket.off()`** — see `listenChat()` in `socket.dart` for the anti-pattern.
4. **Do not call `SharedPreferences.getInstance()` inline** — use `Globals.prefs`.
5. **Do not add `print()`** — use `debugPrint()` and wrap in `kDebugMode` guard.
