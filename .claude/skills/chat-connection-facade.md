# ChatConnection Facade — Initialization Order & Static Field Contract

## What this is

`ChatConnection` (`/lib/connection/chat_connection.dart`) is a **god-object static facade** that:
- Holds ~25 `static` fields as global mutable state
- Delegates every domain operation to 10+ service singletons (RoomService, MessageService, MediaService, GroupService, TagService, ChatHubService, AuthService, etc.)
- Is the **only** entry point the rest of the codebase uses for any network or socket operation

## Mandatory call order — violating this throws LateInitializationError

```
1. Config.getPreferences()          // /lib/common/config.dart — initializes Globals.prefs (SharedPreferences)
2. Chat.open(context, ...)          // /lib/chat.dart — sets buildContext, locale, appIcon, all Function callbacks
3. ChatConnection.connectSocket()   // /lib/chat.dart → socket.dart StreamSocket — opens socket.io connection
4. AuthService.checkUserToken()     // validates JWT, sets currentUser, brandCode
5. AuthService.reAuthenticate()     // refreshes token if expired; sets isChatHub flag
```

`Chat.open()` and `Chat.connectSocket()` are the public plugin API. Host apps MUST call `connectSocket()` before any room or message operation.

## Static late fields — all throw LateInitializationError if accessed before step 2/3

| Field | Set in | Used in | Safe after step |
|-------|--------|---------|-----------------|
| `buildContext` | `chat.dart Chat.open()` | `download.dart:119`, `contacts_screen.dart:114`, `room_list_screen.dart:218` | 2 |
| `locale` | `chat.dart Chat.open()` | localization helpers throughout | 2 |
| `refreshRoom` | `chat.dart Chat.open()` | room list refresh callbacks | 2 |
| `refreshContact` | `chat.dart Chat.open()` | contacts_screen callbacks | 2 |
| `refreshFavorites` | `chat.dart Chat.open()` | favorites callbacks | 2 |
| `refreshNotifications` | `chat.dart Chat.open()` | notification badge | 2 |
| `appIcon` | `chat.dart Chat.open()` | notification display | 2 |
| `homeScreenNotificationHandler` | `chat.dart Chat.open()` | push routing | 2 |
| `chatScreenNotificationHandler` | `chat.dart Chat.open()` | push routing | 2 |

**Rule**: Never access any of the above fields in a service class constructor or in any code path that runs before `Chat.open()` is called by the host app.

## Nullable vs late — ResponseData trap

`ResponseData` in `/lib/data_model/response/` has `late` non-nullable fields:
```dart
late bool isSuccess;
late dynamic data;
late String message;
```

The `catch` path in `HTTPConnection.get()` sets `isSuccess = false` but does **not** set `data` or `message`. Any caller that reads `responseData.data` or `responseData.message` on a failed response hits `LateInitializationError`.

**Safe pattern**:
```dart
final res = await HTTPConnection.get(...);
if (res.isSuccess) {
  // safe to read res.data
} else {
  // do NOT read res.data or res.message here unless you verified they are set
  return null;
}
```

## isChatHub flag — controls API version AND UI branch

`ChatConnection.isChatHub` (bool, set by `AuthService.reAuthenticate()`) is the global product-mode switch.

| What changes | isChatHub == true | isChatHub == false |
|---|---|---|
| Screen shown | `ChatHubScreen` | `InternalChatScreen` |
| Room list screen | `ChatHubRoomListScreen` | `RoomListScreen` |
| API base domain | `https://chathub.epoints.vn/` | `https://chat.epoints.vn/` |
| Message API | `api/v2/messages` | `api/messages` |
| Room list API | `api/v3/list-rooms` | `api/rooms/list` |
| Exclusive features | sessions, summary, notes, channel list, quota | — |

Pattern used throughout service layer:
```dart
final version = ChatConnection.isChatHub ? '/v2' : '';
final url = 'api${version}/messages';
```

Never hardcode the version segment — always derive it from `isChatHub`.

## ChatHub-only features

The following only exist when `isChatHub == true` and their blocs/screens must be guarded:
- Session management (`session.dart`, `chatbot_bloc.dart`)
- Notes (`note_modules/`)
- Summary (`summary.dart`)
- Channel list (`chanel_id` fields — note the typo in field names, kept for API compat)
- Quota notifications (Zalo OA tier response shape)

## Adding a new service method

1. Add a static method on `ChatConnection` that delegates to the appropriate service class.
2. Never put business logic inside `ChatConnection` itself — it is a facade only.
3. Service classes are stateless; all shared state lives on `ChatConnection` static fields.
4. Return `null` or `false` on failure (existing convention) — do not throw from service methods.
