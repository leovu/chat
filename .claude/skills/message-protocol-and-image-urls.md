# Message Event Protocol, Image URL Assembly & Tag/Mention Format

## Socket message protocol

**Event name**: `'message-in'` — used for BOTH inbound (receive) and outbound (send) message events in `socket.dart StreamSocket`.

Listener registered in `listenChat()`:
```dart
socket.on('message-in', (data) { ... });
```

**Critical bug**: `listenChat()` is called on every `_refreshMessage` without first calling `socket.off('message-in')`. This stacks duplicate listeners. When adding any new `socket.on()` call, always pair it with an `off()` before re-registering:
```dart
socket.off('message-in');          // remove previous listener first
socket.on('message-in', handler);  // then register fresh
```

### Outbound message JSON shape

```json
{
  "authorID":    "<ChatConnection.currentUser.id>",
  "content":     "<text or base64 or filename>",
  "contentType": "text | image | file | audio | video",
  "roomID":      "<room.id>",
  "action":      "send",
  "replies":     { /* optional replied-message object */ }
}
```

The `contentType` string must match `flutter_chat_types` `MessageType.name` — however, note that `message.type.name == 'text'` is used as a raw string comparison in `chat_screen.dart:281`. Do not change `contentType` values without updating that comparison.

### Quota response shape (ChatHub / Zalo OA tier)

When `isChatHub == true`, the server may return a quota notification alongside the message response:
```json
{
  "quota": {
    "used": 120,
    "limit": 200,
    "tier": "basic"
  }
}
```
This triggers a UI notification in `ChatHubScreen`. The field is absent in non-ChatHub mode.

### v2 message API toggle

```dart
final msgUrl = ChatConnection.isChatHub ? 'api/v2/messages' : 'api/messages';
```
All calls to `MessageService` must use this pattern — never hardcode the version segment.

---

## Image URL assembly — canonical pattern

Used in at least 6 files: `image_message.dart`, `message.dart`, `photo_view.dart`, `replied_message.dart`, `chat_screen.dart`, `contacts_screen.dart`.

**Template**:
```dart
'${HTTPConnection.domain}api/images/$shieldedID/$size/$brandCode'
```

| Parameter | Source | Values |
|-----------|--------|--------|
| `HTTPConnection.domain` | static field, includes trailing `/` | `https://chathub.epoints.vn/` or `https://chat.epoints.vn/` |
| `shieldedID` | message/user model field `shieldedID` | opaque string from API |
| `size` | caller's choice | `256` (thumbnail/avatar), `512` (full-size preview) |
| `brandCode` | `ChatConnection.brandCode` | brand identifier string set during auth |

**Use 256** for: avatars in room lists, small thumbnails in message bubbles, replied-message previews.
**Use 512** for: full-size image view (`photo_view.dart`), download targets.

Do not construct image URLs with string interpolation in any other format. If the domain changes, it changes only in `HTTPConnection.domain`.

When `shieldedID` is null or empty, render a placeholder — `cached_network_image` with an `errorWidget` fallback is the existing convention.

---

## Tag / mention format

**Encoding**: `@name-id@`
- `name` is the display name of the mentioned user
- `id` is the user's ID
- Separator is `-` (single hyphen between name and id)

**Broadcast mention**: `@all-all@` — mention everyone in the room.

**Where parsing happens**:
- `localization/check_tag.dart` — `checkTag()` function strips the `@...-id@` markers and returns plain text
- `chat_screen.dart` — `checkTagWidget()` method on `ChatScreenBaseState` converts tag tokens to styled inline spans for the message bubble
- The `@` and trailing `@` delimiters are the signal — plain `@name` without a closing `@` is NOT a tag

**Mention input flow** (in `chat_screen/` input area):
1. User types `@` → show member list overlay
2. On member select → insert `@displayName-userID@` into `RichTextController`
3. On send → content is transmitted raw (server stores the `@name-id@` tokens)
4. On render → `checkTagWidget()` converts tokens to colored spans

**`rich_text_controller`** (`^3.0.1`) is used for the input field to highlight `@name-id@` tokens while typing.

---

## Message type discrimination

`flutter_chat_types` types are used for the message model. However, the `chat_screen/` layer (older code) compares types as raw strings:

```dart
// chat_screen.dart:281 — DO NOT change to enum without updating this
if (message.type.name == 'text') { ... }
```

The `presentation/` layer (newer code) correctly uses:
```dart
if (message is types.TextMessage) { ... }
```

When working in `presentation/` code, use the typed pattern. When working in `chat_screen/` code, match the existing string comparison to avoid breaking the build.
