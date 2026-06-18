# LiquidGlassTabBar — Tài liệu tích hợp & sửa lỗi

## Tổng quan

Thay thế `CupertinoTabScaffold` + `CupertinoTabBar` trong `home_screen.dart` bằng widget `LiquidGlassTabBar` tùy chỉnh, sử dụng `Scaffold` + `IndexedStack` + `bottomNavigationBar` với hiệu ứng Liquid Glass (frosted glass kiểu iOS).

---

## 1. File mới: `lib/common/widgets/liquid_glass_tab_bar.dart`

### Nguồn gốc
Lấy từ project wasucowork, chỉnh sửa cho phù hợp theme chat.

### Import cần thiết
```dart
import 'dart:ui';                          // BackdropFilter, ImageFilter
import 'package:chat/chat_ui/chat_theme.dart';
import 'package:flutter/material.dart';
```

### Các class

#### `LiquidGlassTabItem`
```dart
class LiquidGlassTabItem {
  final dynamic id;
  final String? title;
  final IconData? iconData;
  final String? iconAsset;
  final int? badgeCount;
  final Widget? customChild;
}
```

#### `LiquidGlassTabBar` — props chính
| Prop | Type | Mặc định | Mô tả |
|---|---|---|---|
| `items` | `List<LiquidGlassTabItem>` | bắt buộc | Danh sách tab |
| `selectedIndex` | `int` | `0` | Index tab đang chọn |
| `onTabChanged` | `Function(int, LiquidGlassTabItem)?` | null | Callback khi đổi tab |
| `indicatorColor` | `Color?` | `Colors.transparent` | Màu indicator (transparent = glass) |
| `selectedColor` | `Color?` | `primaryColor` | Màu icon/text khi active |
| `unselectedColor` | `Color?` | `primaryColor` | Màu icon/text khi inactive |
| `expandItems` | `bool` | `false` | Tab mở rộng theo flex |
| `animationDuration` | `int` | `400` | Thời gian animation (ms) |

### Chỉnh sửa so với bản gốc wasucowork

| Hạng mục | Wasucowork gốc | Chat version hiện tại |
|---|---|---|
| Color primary | `AppColors.primaryColor` | `primaryColor` từ `chat_ui/chat_theme.dart` |
| Màu selected | `Colors.white` | `primaryColor` (đổi do indicator transparent) |
| Màu unselected | Tùy biến | `primaryColor` |
| Màu badge | Tùy biến | `Colors.red` |
| Indicator | Gradient solid color | Frosted glass (BackdropFilter + blur) |
| indicatorColor default | `primaryColor` | `Colors.transparent` |

### Logic hiển thị title (active vs inactive)
```dart
String _abbreviate(String title) {
  return title
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase())
      .join('');
}

// Trong _buildDefaultTabContent:
final displayTitle = item.title != null
    ? (isSelected ? item.title! : _abbreviate(item.title!))
    : null;
```
- Tab **active**: hiển thị full title ("Cuộc trò chuyện")
- Tab **inactive**: hiển thị viết tắt ("CTG")

### Phân bổ flex khi `expandItems: true`
```dart
return widget.expandItems
    ? Expanded(flex: isSelected ? 2 : 1, child: tabButton)
    : tabButton;
```
- Tab active: `flex: 2` (chiếm nhiều không gian hơn để hiện full title)
- Tab inactive: `flex: 1`

### `_LiquidGlassIndicator` — hiệu ứng glass pill

```dart
Widget build(BuildContext context) {
  // Hiệu ứng stretch khi đang animate (liquid feel)
  final stretchX = isAnimating ? 1.0 + (0.1 * (1 - (2 * progress - 1).abs())) : 1.0;
  final stretchY = isAnimating ? 1.0 - (0.05 * (1 - (2 * progress - 1).abs())) : 1.0;
  return Transform(
    alignment: Alignment.center,
    transform: Matrix4.diagonal3Values(stretchX, stretchY, 1.0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            // Nền trắng 25% (pill sáng hơn nền tab bar 12%)
            color: color != Colors.transparent
                ? color.withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(borderRadius),
            // Viền primaryColor mờ để pill không bị "chìm"
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.4),
              width: 1.2,
            ),
          ),
        ),
      ),
    ),
  );
}
```

**Lưu ý opacity:**
- Tab bar background: `white 12%`
- Indicator pill: `white 25%` → pill sáng hơn nền, dễ nhận biết tab active
- Viền pill: `primaryColor 40%` → viền rõ, không bị "chìm" trên nền trắng

---

## 2. Sửa đổi `lib/chat_screen/home_screen.dart`

### Import thêm
```dart
import 'dart:ui'; // BackdropFilter, ImageFilter
```

### Trước (CupertinoTabScaffold)
```dart
import 'package:badges/badges.dart' as badges;

return CupertinoTabScaffold(
  tabBar: CupertinoTabBar(items: [...]),
  tabBuilder: (context, index) => CupertinoTabView(
    builder: (context) => screens[index],
  ),
);
```

### Sau (Scaffold + IndexedStack + Glass bottom bar)

**State mới:**
```dart
int _chatTabIndex = 0;
int _chatHubTabIndex = 0;
```

**`_chat()` — 4 tab:**
```dart
Widget _chat() {
  return Scaffold(
    extendBody: true,           // Body kéo dài xuống sau tab bar
    body: IndexedStack(
      index: _chatTabIndex,
      children: [
        RoomListScreen(...),
        ContactsScreen(...),
        FavoriteScreen(...),
        NotificationScreen(...),
      ],
    ),
    bottomNavigationBar: _buildChatTabBar(),
  );
}
```

**`_chatHub()` — 2 tab:**
```dart
Widget _chatHub() {
  return Scaffold(
    extendBody: true,
    body: IndexedStack(
      index: _chatHubTabIndex,
      children: [
        RoomListChathubScreen(...),
        NotificationScreen(...),
      ],
    ),
    bottomNavigationBar: _buildChatHubTabBar(),
  );
}
```

**`_buildChatTabBar()` — glass tab bar 4 item:**
```dart
Widget _buildChatTabBar() {
  return ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),   // nền 12%
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.4), width: 0.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: ValueListenableBuilder<String>(
              valueListenable: ChatConnection.notificationNotifier,
              builder: (context, notifValue, _) {
                final notifCount = int.tryParse(notifValue) ?? 0;
                return LiquidGlassTabBar(
                  selectedIndex: _chatTabIndex,
                  expandItems: true,
                  onTabChanged: (index, item) {
                    if (index == 3) {
                      try { ChatConnection.refreshNotifications.call(); } catch (_) {}
                    }
                    setState(() => _chatTabIndex = index);
                  },
                  items: [
                    LiquidGlassTabItem(iconData: Icons.chat, title: AppLocalizations.text(LangKey.chats)),
                    LiquidGlassTabItem(iconData: Icons.contact_mail, title: AppLocalizations.text(LangKey.contacts)),
                    LiquidGlassTabItem(iconData: Icons.star_border, title: AppLocalizations.text(LangKey.favorites)),
                    LiquidGlassTabItem(iconData: Icons.notifications, title: AppLocalizations.text(LangKey.notifications), badgeCount: notifCount),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}
```

**Tại sao dùng `extendBody: true`:**
- Cho phép body kéo dài xuống sau tab bar → nền content lộ qua lớp glass
- Flutter tự điều chỉnh `MediaQuery.padding.bottom` của child Scaffolds để tránh content bị che khuất

---

## 3. Các lỗi đã sửa

### Bug 1: `StreamSocket` bad state after close

**Lỗi:** `Bad state: Cannot add new events after calling close`

**Nguyên nhân:** `addResponse` là getter trả về `sink.add` trực tiếp. Sau khi `dispose()` đóng StreamController, socket vẫn tiếp tục gọi `sink.add`.

**File:** `lib/connection/socket.dart`

```dart
// Trước
Sink<String> get addResponse => _socketResponse.sink;

// Sau
void addResponse(String data) {
  if (!_socketResponse.isClosed) _socketResponse.sink.add(data);
}
```

---

### Bug 2: `LateInitializationError` — Field 'refreshRoom' has not been initialized

**Nguyên nhân:** `IndexedStack` build tất cả children ngay lập tức. `FavoriteScreen` và `NotificationScreen` dùng `ChatConnection.refreshRoom.call` làm callback trực tiếp trước khi `RoomListScreen` kịp khởi tạo `refreshRoom`.

**File:** `lib/chat_screen/home_screen.dart`

```dart
// Trước
homeCallback: ChatConnection.refreshRoom.call,

// Sau
homeCallback: () {
  try { ChatConnection.refreshRoom.call(); } catch (_) {}
},
```

---

### Bug 3: Lớp phủ trắng trên tab button

**Nguyên nhân:** `InkWell` mặc định có `highlightColor` màu trắng.

**File:** `lib/common/widgets/liquid_glass_tab_bar.dart`

```dart
// Sau
InkWell(
  onTap: widget.onTap,
  highlightColor: Colors.transparent,
  splashColor: Colors.transparent,
  overlayColor: WidgetStateProperty.all(Colors.transparent),
  child: ...,
)
```

---

### Bug 4: RenderFlex overflow khi title active quá dài

**Lỗi:** `RenderFlex overflowed by 43 pixels on the right.`

**Nguyên nhân:** Tất cả tab có flex = 1, tab active hiển thị full title làm tràn.

**File:** `lib/common/widgets/liquid_glass_tab_bar.dart`

```dart
// 1. Flex động
Expanded(flex: isSelected ? 2 : 1, child: tabButton)

// 2. Text bọc Flexible
Flexible(
  child: AnimatedDefaultTextStyle(
    child: Text(displayTitle, overflow: TextOverflow.ellipsis, maxLines: 1),
  ),
)

// 3. Row content
Row(
  mainAxisSize: MainAxisSize.max,
  mainAxisAlignment: MainAxisAlignment.center,
  children: [...],
)
```

---

### Bug 5: `bottomNavigationBar` chiếm toàn màn hình

**Lỗi:** Tab bar chiếm toàn bộ màn hình, `IndexedStack` không hiển thị.

**Nguyên nhân:** `Container(alignment: Alignment.center)` bên trong `_LiquidGlassTabButton` — khi `alignment` được set trên Container không có height tường minh trong Stack (loose height constraints), Container phình to hết màn hình.

**File:** `lib/common/widgets/liquid_glass_tab_bar.dart`

```dart
// Trước
child: Container(
  padding: widget.padding,
  width: double.infinity,
  alignment: Alignment.center,
  child: widget.child,
),

// Sau
child: Container(padding: widget.padding, child: widget.child),
```

---

### Bug 6: Content active không hiển thị khi indicator transparent

**Nguyên nhân:** `selectedColor` mặc định là `Colors.white` — icon/text trắng trên nền indicator trắng mờ → vô hình.

**File:** `lib/common/widgets/liquid_glass_tab_bar.dart`

```dart
// Trước
final selectedColor = widget.selectedColor ?? Colors.white;

// Sau
final selectedColor = widget.selectedColor ?? primaryColor;
```

---

## 4. Cấu trúc file

```
lib/
├── common/
│   └── widgets/
│       └── liquid_glass_tab_bar.dart   ← FILE MỚI
├── chat_screen/
│   └── home_screen.dart                ← SỬA ĐỔI
└── connection/
    └── socket.dart                     ← SỬA ĐỔI (addResponse)
```

---

## 5. Luồng constraint layout

```
Scaffold(extendBody: true)
  ├── body: IndexedStack (kéo dài xuống sau tab bar)
  └── bottomNavigationBar:
      ClipRect
        └── BackdropFilter(blur: 20)        ← làm mờ nội dung phía sau
            └── Container(white 12%)        ← nền glass tab bar
                └── SafeArea(top: false)
                    └── Padding(h:8, v:6)
                        └── LiquidGlassTabBar
                            └── Stack
                                ├── Positioned → _LiquidGlassIndicator
                                │   ClipRRect → BackdropFilter(blur: 12)
                                │   └── Container(white 25%, border primary 40%)
                                └── Row(spaceAround)
                                    ├── Expanded(flex:2) → Button [active]
                                    │   Material → InkWell → Container → content
                                    └── Expanded(flex:1) → Button [inactive]
                                        Material → InkWell → Container → content
```

**Phân lớp opacity:**
| Layer | Background | Mục đích |
|---|---|---|
| Tab bar container | white 12% | Nền glass chính, xuyên thấu |
| Indicator pill | white 25% | Nổi bật hơn nền, đánh dấu tab active |
| Indicator border | primaryColor 40% | Viền rõ, pill không "chìm" |
| Text / Icon | 100% opaque | Đọc được, contrast tốt |

Tổng chiều cao bottomNavigationBar ≈ 40px (content) + 34px (SafeArea bottom iPhone) + 12px (Padding) = ~86px.
