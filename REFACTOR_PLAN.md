# Kế hoạch Refactor — Chat Plugin (`lib/`)

> Tài liệu này mô tả toàn bộ kế hoạch tái cấu trúc codebase.
> Chỉnh sửa trực tiếp file này trước khi bắt đầu thực hiện.

---

## 1. Vấn đề hiện tại

### 1.1 Avatar bị duplicate ở 18 file

Cùng một logic hiển thị avatar (picture → shieldedID → initials) được viết lại
thủ công tại từng màn hình:

| File | Widget/Method |
|------|---------------|
| `room_list_screen.dart` | `_buildSingleAvatar`, `_buildGroupAvatar` |
| `chat_screen.dart` | `buildAvatar()` |
| `conversation_information_screen.dart` | `_buildAppropriateAvatar()` |
| `common_avatar.dart` | `CommonAvatar` (thiếu ChatHub, thiếu whatsapp) |
| `forward_screen.dart` | inline ternary |
| `favorite_screen.dart` | inline ternary |
| `notification_screen.dart` | inline ternary |
| `contacts_screen.dart` | inline ternary |
| `add_member_group_screen.dart` | inline ternary |
| `chat_group_members_screen.dart` | inline ternary |
| … (8 file khác) | rải rác |

### 1.2 Source icon badge bị duplicate

`_sourceIconMap` / nested ternary để chọn icon platform (zalo/facebook/whatsapp…)
xuất hiện ít nhất ở 3 nơi: `room_list_screen`, `common_avatar.dart`,
`chathub_room_list_screen`. Khi thêm platform mới phải sửa nhiều chỗ.

### 1.3 `isChatHub` branching rải rác ở 17 file

Cùng một màn hình (`room_list_screen`, `chat_screen`…) vừa xử lý logic Chat
thường vừa xử lý ChatHub, dẫn đến khối `if (isChatHub) { ... } else { ... }`
khổng lồ, khó đọc, khó test.

### 1.4 Màn hình quá lớn

| File | Dòng |
|------|------|
| `room_list_screen.dart` | ~1 450 |
| `chat_screen.dart` | ~2 161 |
| `conversation_information_screen.dart` | ~2 148 |

Mỗi file ôm cả UI, state, network call, helper method → sửa một chỗ ảnh hưởng
nhiều nơi.

---

## 2. Cấu trúc đề xuất

```
lib/
├── common/
│   ├── assets.dart                  # (giữ nguyên)
│   ├── base_bloc.dart               # (giữ nguyên)
│   ├── config.dart                  # (giữ nguyên)
│   ├── constants.dart               # ← MỚI: source icon map, màu platform
│   ├── global.dart                  # (giữ nguyên)
│   ├── theme.dart                   # (giữ nguyên)
│   └── widgets/
│       ├── room_avatar.dart         # ← MỚI: widget avatar dùng chung toàn app
│       ├── source_badge.dart        # ← MỚI: badge platform nhỏ góc avatar
│       ├── unread_badge.dart        # ← MỚI: số tin chưa đọc
│       └── …                        # (các widget hiện có giữ nguyên)
│
├── data_model/                      # (giữ nguyên)
│
├── connection/                      # (giữ nguyên)
│
├── localization/                    # (giữ nguyên)
│
├── chat_screen/                     # Entry-point screens (navigation level)
│   ├── home_screen.dart             # (giữ nguyên)
│   ├── chathub_room_list_screen.dart# (giữ nguyên — tab host)
│   ├── room_list_screen.dart        # ← TÁCH: chỉ còn layout + list
│   └── …
│
└── presentation/
    ├── chat_module/
    │   ├── bloc/chat_bloc.dart      # (giữ nguyên)
    │   └── ui/
    │       ├── chat_screen.dart     # ← TÁCH: AppBar, message list
    │       ├── chat_appbar.dart     # ← MỚI: AppBar widget riêng
    │       └── chat_input_bar.dart  # ← MỚI: Input bar widget riêng
    │
    ├── conversation_modules/
    │   └── src/ui/
    │       ├── conversation_information_screen.dart  # ← TÁCH: chỉ layout
    │       ├── conversation_info_header.dart         # ← MỚI: avatar + tên
    │       └── conversation_info_actions.dart        # ← MỚI: action buttons
    │
    └── utils/
        ├── ultility.dart            # (giữ nguyên: getAvatarName, etc.)
        └── …
```

---

## 3. Các widget dùng chung cần tạo

### 3.1 `RoomAvatar` — thay thế 18 chỗ hiện tại

```dart
/// lib/common/widgets/room_avatar.dart
///
/// Dùng cho CẢ Chat và ChatHub.
/// Tự xử lý logic: picture → avatar url → shieldedID → initials.
///
/// Cách dùng:
///   RoomAvatar(room: data, radius: 25)
///   RoomAvatar(room: data, radius: 40, showSourceBadge: true)

class RoomAvatar extends StatelessWidget {
  final Rooms room;
  final double radius;
  final bool showSourceBadge;   // hiện badge platform ở góc (mặc định false)
  …
}
```

**Logic bên trong:**
- Non-group: `_buildSingleAvatar()` — picture null → dùng avatar url → initials
- Group: `_buildGroupAvatar()` — room_avatar/shieldedID → GroupAvatar → initials
- Badge: dùng `SourceBadge` (3.2) nếu `showSourceBadge == true`

### 3.2 `SourceBadge` — thay thế nested ternary hiện tại

```dart
/// lib/common/widgets/source_badge.dart
///
/// Để thêm platform mới: chỉ thêm 1 dòng vào _iconMap

class SourceBadge extends StatelessWidget {
  final String? source;
  …
  static const Map<String, String> _iconMap = {
    'zalo':          'assets/icon-zalo.png',
    'zalo_personal': 'assets/icon_zalo_personal.png',
    'client':        'assets/icon_chat_client.png',
    'facebook':      'assets/icon-facebook.png',
    'whatsapp':      'assets/icon_whatsapp.png',
    // thêm platform mới ở đây
  };
}
```

### 3.3 `UnreadBadge` — số tin chưa đọc

```dart
/// lib/common/widgets/unread_badge.dart
class UnreadBadge extends StatelessWidget {
  final String count;   // '0', '5', '99+'
  …
}
```

---

## 4. Các bước thực hiện

### Phase 1 — Nền tảng (không ảnh hưởng UI hiện tại)

| Bước | Công việc | File tạo/sửa | Ước tính |
|------|-----------|--------------|----------|
| 1.1 | Tạo `SourceBadge` widget | `common/widgets/source_badge.dart` | 1h |
| 1.2 | Tạo `UnreadBadge` widget | `common/widgets/unread_badge.dart` | 0.5h |
| 1.3 | Tạo `RoomAvatar` widget (hỗ trợ cả Chat + ChatHub) | `common/widgets/room_avatar.dart` | 3h |
| 1.4 | Update `widget.dart` (barrel file) để export 3 widget mới | `common/widgets/widget.dart` | 0.25h |

### Phase 2 — Thay thế avatar rải rác (không đổi logic)

| Bước | File cần sửa | Đổi gì | Ước tính |
|------|-------------|--------|----------|
| 2.1 | `common_avatar.dart` | Dùng `RoomAvatar` + `SourceBadge`, bổ sung whatsapp | 0.5h |
| 2.2 | `room_list_screen.dart` | Thay `_buildSingleAvatar`/`_buildGroupAvatar`/`_buildSourceBadge` bằng `RoomAvatar` | 1h |
| 2.3 | `chat_screen.dart` | Thay `buildAvatar()` bằng `RoomAvatar` | 1h |
| 2.4 | `conversation_information_screen.dart` | Thay `_buildAvatar`/`_buildAppropriateAvatar` bằng `RoomAvatar` | 1h |
| 2.5 | 8 file còn lại (`forward`, `favorite`, `notification`, `contacts`, `add_member`, `chat_group_members` …) | Inline ternary → `RoomAvatar` | 2h |

### Phase 3 — Tách màn hình lớn (tuỳ chọn, làm sau)

| Bước | File | Tách thành | Ước tính |
|------|------|-----------|----------|
| 3.1 | `chat_screen.dart` (2161 dòng) | `chat_appbar.dart` + `chat_input_bar.dart` + file chính còn ~800 dòng | 4h |
| 3.2 | `room_list_screen.dart` (~1450 dòng) | `room_list_item.dart` (item widget) + file chính còn ~600 dòng | 3h |
| 3.3 | `conversation_information_screen.dart` (~2148 dòng) | `conversation_info_header.dart` + `conversation_info_actions.dart` | 3h |

### Phase 4 — Giảm `isChatHub` branching (dài hạn)

Hiện tại 17 file có `if (isChatHub)` inline. Cách xử lý:

- **Không** tạo 2 class riêng cho mỗi màn hình (quá nhiều code).
- **Thay vào đó**: Đẩy `isChatHub` logic vào model/helper, UI chỉ nhận data đã
  được xử lý.
- Ví dụ: `RoomDisplayData` (DTO) chứa `displayName`, `avatarUrl`, `sourceBadge`
  — tính sẵn trong bloc, UI chỉ render.

| Bước | Công việc | Ước tính |
|------|-----------|----------|
| 4.1 | Tạo `RoomDisplayData` DTO | 2h |
| 4.2 | Tính `RoomDisplayData` trong bloc/state | 4h |
| 4.3 | UI chỉ render từ DTO, bỏ `isChatHub` inline | 6h |

---

## 5. Ước tính thời gian tổng

| Phase | Công việc | Thời gian |
|-------|-----------|-----------|
| Phase 1 | Tạo 3 widget dùng chung | ~5h |
| Phase 2 | Thay thế avatar 11 file | ~6h |
| Phase 3 | Tách 3 màn hình lớn | ~10h |
| Phase 4 | Giảm `isChatHub` branching | ~12h |
| **Tổng** | | **~33h** |

> **Đề xuất thứ tự:** Phase 1 → Phase 2 → Phase 3.
> Phase 4 chỉ khi có thời gian dài hạn, vì ảnh hưởng nhiều file nhất.

---

## 6. Quy tắc áp dụng trong quá trình refactor

1. **Không đổi logic, chỉ đổi cấu trúc** — test UI trước và sau mỗi Phase.
2. **Một commit per bước** — dễ revert nếu có vấn đề.
3. **`RoomAvatar` là single source of truth** — không viết inline CircleAvatar
   mới sau khi Phase 2 xong.
4. **Thêm platform mới**: chỉ thêm 1 dòng vào `SourceBadge._iconMap`.
5. **Không xoá `CommonAvatar`** cho đến khi tất cả caller đã chuyển sang
   `RoomAvatar` (Phase 2.1).

---

## 7. Trạng thái hiện tại (2026-03-16)

- [x] Đã tạo `_buildSingleAvatar`, `_buildGroupAvatar`, `_buildSourceBadge`,
      `_sourceIconMap` trong `room_list_screen.dart`
- [x] Đã fix bug `&&` → `||` trong `chat_screen.dart` `buildAvatar()`
- [x] `conversation_information_screen.dart` — avatar logic đã sạch
- [ ] Phase 1: Chưa bắt đầu
- [ ] Phase 2: Chưa bắt đầu
- [ ] Phase 3: Chưa bắt đầu
- [ ] Phase 4: Chưa bắt đầu
