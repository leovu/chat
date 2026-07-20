# ChatConnection God-Object API Reference

## What this skill covers
`lib/connection/chat_connection.dart` (~1270 lines) is the static singleton that owns ALL business logic. Use this reference when modifying any API call, callback, or multi-tenancy branch.

## Plugin Entry Point: Chat.open() in lib/chat.dart

The host app calls `Chat.open(...)`. Every parameter below maps to a field set on `ChatConnection` before navigation:

| Parameter | Type | ChatConnection field | Purpose |
|---|---|---|---|
| email | String | `email` | Login credential |
| password | String | `password` | Login credential |
| domain | String | `domain` | Tenant domain prefix |
| token | String? | `token` | Pre-issued auth token (skips login) |
| brandCode | String | `brandCode` | HTTP header value for tenant routing |
| locale | String | `locale` | 'vi' or 'en' -- drives AppLocalizations |
| isChatHub | bool | `isChatHub` | Multi-tenancy mode flag (see below) |
| notificationData | Map? | `notificationData` | Deep-link notification payload |
| phoneNumber | String? | `phoneNumber` | Open chat by phone lookup |
| roomId | String? | `roomId` | Open specific room directly |
| addOnModules | List<Map>? | `addOnModules` | Feature buttons injected into chat UI |

### addOnModules list item shape
Each map in the list must have exactly these keys:
```dart
{
  'key': String,       // unique identifier
  'name': String,      // display label
  'icon': Widget,      // icon widget rendered in toolbar
  'function': Function // called with no args when tapped
}
```

## Optional Function Callbacks on ChatConnection

All are `static Function?` fields. They are assigned by the host screen in `initState` and are NEVER null-checked before invocation -- **calling them before assignment throws LateInitializationError**.

| Field | Signature hint | Purpose |
|---|---|---|
| `searchProducts` | `Function?` | Open host's product search UI |
| `searchOrders` | `Function?` | Open host's order search UI |
| `createOrder` | `Function?` | Trigger order creation from chat |
| `createAppointment` | `Function?` | Trigger appointment creation |
| `createDeal` | `Function?` | Trigger CRM deal creation |
| `createTask` | `Function?` | Trigger task creation |
| `addCustomer` | `Function?` | Add new customer from chat |
| `addCustomerPotential` | `Function?` | Add lead/potential customer |
| `viewProfileChatHub` | `Function?` | Open contact profile in host app |
| `editCustomerLead` | `Function?` | Edit lead record |
| `openChatGPT` | `Function?` | Open AI assistant integration |
| `homeScreenNotificationHandler` | `static late Function` | Assigned in HomeScreen.initState -- CRASH if called before |
| `chatScreenNotificationHandler` | `static late Function` | Assigned in ChatScreen.initState -- CRASH if called before |
| `refreshRoom` | `static late Function` | Triggers room list refresh |
| `refreshContact` | `static late Function` | Triggers contact list refresh |
| `refreshFavorites` | `static late Function` | Triggers favorites list refresh |
| `refreshNotifications` | `static late Function` | Triggers notification badge refresh |

**Rule**: Always guard `static late Function` calls: assign a no-op default before navigating, or null-check via a nullable type.

## isChatHub Multi-Tenancy: URL Versioning

`ChatConnection.isChatHub` is the primary branching flag. Pattern used everywhere:
```dart
String version = ChatConnection.isChatHub ? '/v2' : '';
// then: 'api${version}/rooms/list'
```

Key endpoint differences (isChatHub=true vs false):

| Feature | isChatHub=false | isChatHub=true |
|---|---|---|
| Room list | `api/rooms/list` | `api/v2/rooms/list` |
| Join room | `api/room/join` | `api/v3/join-room` |
| (all others) | base path | versioned path |

This branching appears in ~20 locations. When adding new API calls, always add the `isChatHub` ternary or use the `version` variable pattern. Do NOT create a new base URL -- `HTTPConnection.domain` is hardcoded based on the same flag.

## HTTPConnection: The HTTP Layer

File: `lib/connection/http_connection.dart`

- `domain`: conditionally hardcoded based on `isChatHub`; no runtime config
- Methods: `post(path, body)`, `get(path)`, `upload(path, file)`, `postReturnList(path, body)`
- Auth: adds `Authorization: Bearer <token>` header from `ChatConnection.token`
- Brand header: `brand-code` header is added via `headers.addAll(header)` -- **known bug at line 76: was `headers.addAll(headers)` (self-merge no-op) meaning brand-code was silently dropped**

## Socket

`ChatConnection.streamSocket` is a `StreamSocket` instance from `lib/connection/socket.dart`.
- Init: `StreamSocket.init()` -- **applies global SSL bypass via `HttpOverrides.global`**
- Token refresh: `StreamSocket.token()` -- also applies SSL bypass
- Reconnect lifecycle: wired in `lib/connection/app_lifecycle.dart` via `AppLifeCycle` mixin
  - **Warning**: `ChatConnection.dispose()` is called on BOTH `inactive` AND `paused` states -- on iOS, system dialogs trigger `inactive`, causing spurious socket kills

## notificationCount() Bug (chat_connection.dart:215)

```dart
// WRONG (current code):
notiChatHubZalo = result.zalo;
notiChatHubZalo = result.zalo_personal;  // overwrites zalo, never sets notiChatHubZaloPersonal

// CORRECT fix:
notiChatHubZalo = result.zalo;
notiChatHubZaloPersonal = result.zalo_personal;
```
