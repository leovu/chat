# Kiến trúc dự án Flutter — Bloc-Screen Pattern

Tài liệu này mô tả kiến trúc chuẩn của dự án để áp dụng khi refactor source khác sang cùng cấu trúc.

---

## 1. Cấu trúc thư mục

```
lib/
├── main.dart
├── common/
│   ├── globals.dart              # Singleton: prefs, config, user model, main bloc
│   ├── theme.dart                # AppColors, AppSizes, AppTextSizes, AppFormat (DateFormat)
│   ├── constant.dart             # Hằng số toàn cục, filter options
│   ├── utilities.dart            # Hàm tiện ích: init, copyText, showDatePicker...
│   ├── config.dart               # Config model (đọc từ assets/json/config.json)
│   ├── assets.dart               # Đường dẫn asset (ảnh, icon)
│   ├── app_format.dart           # CustomAppFormat: formatDate, formatMoney, parseDate...
│   └── localization/
│       ├── l10n.dart             # LangKey — tất cả string đa ngữ
│       └── intl/
│           ├── messages_vi.dart
│           └── messages_en.dart
├── data/
│   ├── models/
│   │   ├── base/
│   │   │   └── response_model.dart   # ResponseModel (errorCode, data, datas, success)
│   │   ├── request/                  # *_req_model.dart — toJson()
│   │   └── response/                 # *_res_model.dart — fromJson()
│   ├── network/
│   │   ├── api/api.dart              # Endpoint strings tập trung
│   │   └── http/http_connection.dart # Abstract HTTP base (GET/POST/Multipart)
│   └── local/
│       └── shared_prefs/
│           ├── shared_prefs_key.dart  # Hằng tên key
│           └── shared_prefs.dart      # Wrapper SharedPreferences
├── domain/
│   ├── repository.dart               # Static methods, 1 method = 1 API call
│   └── interaction/interaction.dart  # Extends HttpConnection, xử lý token/lỗi
└── presentation/
    ├── base/
    │   └── base_view.dart            # BaseView + BaseBloc + extensions
    ├── module/
    │   ├── authen_module/            # Login, Splash
    │   └── main_module/
    │       ├── src/
    │       │   ├── bloc/main_bloc.dart
    │       │   └── ui/main_screen.dart
    │       └── module/               # Mỗi feature = 1 thư mục con
    │           └── [feature_name]/
    │               ├── src/
    │               │   ├── bloc/[feature]_bloc.dart
    │               │   └── ui/[feature]_screen.dart
    │               └── module/       # Sub-feature lồng nhau (nếu có)
    │                   └── [sub_feature]/
    │                       ├── bloc/
    │                       └── ui/
    └── widget/
        ├── widget.dart               # Barrel file (library widget; part '...')
        ├── custom_*.dart             # Widget đơn giản
        └── container_*.dart          # Widget phức tạp có state/stream
```

---

## 2. BaseView & BaseBloc

**File:** `lib/presentation/base/base_view.dart`

### Quy tắc cốt lõi

- **Screen** = class extends `BaseView` (StatefulWidget)
- **Bloc** = class extends `BaseBloc<TênScreen>` (State)
- Screen tạo bloc inline: `final MyBloc _bloc = MyBloc();`
- `createState()` trả về chính `_bloc`
- Bloc có thể truy cập `context` qua `widget.context` (được gán trong `initState`)

### Skeleton Screen

```dart
class MyScreen extends BaseView {
  final MyBloc _bloc = MyBloc();

  @override
  MyBloc createState() => _bloc;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Tiêu đề',
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return StreamBuilder<List<Item>?>(
      stream: _bloc.streamItems,
      builder: (context, snapshot) {
        final items = snapshot.data;
        if (items == null) return const Center(child: CircularProgressIndicator());
        if (items.isEmpty) return Center(child: CustomText(text: 'Không có dữ liệu'));
        return CustomListView(
          children: items.map((e) => _buildItem(e)).toList(),
        );
      },
    );
  }
}
```

### Skeleton Bloc

```dart
class MyBloc extends BaseBloc<MyScreen> {
  // --- Streams ---
  final streamItems = BehaviorSubject<List<Item>?>();
  final streamLoading = BehaviorSubject<bool>.seeded(false);

  // --- State ---
  int _currentPage = 1;

  // --- Lifecycle ---
  @override
  void onInit() {
    // Gọi ngay khi widget được tạo (đồng bộ)
  }

  @override
  void onReady() {
    // Gọi sau frame đầu tiên — nơi fetch API
    _fetchData();
  }

  @override
  void onResumed() {
    // App từ background trở lại foreground
  }

  @override
  void onDispose() {
    // Đóng tất cả stream + dispose controller
    streamItems.close();
    streamLoading.close();
  }

  // --- Methods ---
  _fetchData() async {
    streamLoading.set(true);
    final response = await Repository.myApi(context, MyReqModel());
    if (response.success) {
      final data = MyResModel.fromJson(response.data);
      streamItems.set(data.items);
    }
    streamLoading.set(false);
  }
}
```

### Extensions quan trọng

```dart
// BehaviorSubject.set() — thêm giá trị an toàn (kiểm tra isClosed)
streamItems.set(data);

// BehaviorSubject.output — lấy stream để dùng trong StreamBuilder
stream: _bloc.streamItems.output  // hoặc trực tiếp _bloc.streamItems

// Context extensions
context.width      // double — chiều rộng màn hình
context.height     // double — chiều cao màn hình
context.sizePerRow(count: 2)  // width chia đều N cột
```

---

## 3. State Management — BehaviorSubject

Toàn bộ state reactive dùng `BehaviorSubject` từ package `rxdart`.

```dart
// Khai báo
final streamData = BehaviorSubject<List<Model>?>();          // nullable, chưa có giá trị ban đầu
final streamLoading = BehaviorSubject<bool>.seeded(false);   // có giá trị ban đầu

// Phát giá trị
streamData.set(list);

// Lắng nghe trong UI
StreamBuilder<List<Model>?>(
  stream: _bloc.streamData,
  builder: (context, snapshot) {
    final data = snapshot.data;
    // null = đang load / chưa có
    // [] = rỗng
    // [...] = có dữ liệu
    ...
  },
)

// Đọc giá trị hiện tại trong bloc
final current = streamData.valueOrNull;

// Cleanup bắt buộc trong onDispose()
streamData.close();
```

---

## 4. Data Layer

### Request Model

```dart
class MyReqModel {
  final String? keyword;
  final int? page;
  final int pageSize;

  MyReqModel({this.keyword, this.page, this.pageSize = 20});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (keyword?.isNotEmpty == true) data['keyword'] = keyword;
    if (page != null) data['page'] = page;
    data['page_size'] = pageSize;
    return data;
  }
}
```

### Response Model

```dart
class MyResModel {
  final List<MyItemModel>? items;
  final int? total;

  MyResModel({this.items, this.total});

  factory MyResModel.fromJson(Map<String, dynamic> json) {
    return MyResModel(
      items: (json['items'] as List?)?.map((e) => MyItemModel.fromJson(e)).toList(),
      total: json['total'],
    );
  }
}

class MyItemModel {
  final String? id;
  final String? name;

  MyItemModel({this.id, this.name});

  factory MyItemModel.fromJson(Map<String, dynamic> json) {
    return MyItemModel(
      id: json['id']?.toString(),
      name: json['name'],
    );
  }
}
```

### ResponseModel (base)

```dart
// Mọi API call đều trả ResponseModel
class ResponseModel {
  bool success;        // errorCode == 0
  int? errorCode;
  String? errorMessage;
  Map<String, dynamic> data;   // khi API trả object
  List<dynamic> datas;         // khi API trả array
}

// Dùng trong bloc
final response = await Repository.myApi(context, request);
if (response.success) {
  final model = MyResModel.fromJson(response.data);   // object
  // hoặc
  final list = MyResModel.parseList(response.datas);  // array
}
```

### Repository

```dart
// lib/domain/repository.dart
class Repository {
  // Mỗi API = 1 static method
  static myEndpoint(BuildContext context, MyReqModel model) =>
      Interaction(
        context: context,
        url: API.myEndpoint(),    // String endpoint
        param: model.toJson(),
        showError: true,          // false = tự xử lý lỗi
      ).post();

  // Upload file
  static uploadFile(BuildContext context, File file) =>
      Interaction(
        context: context,
        url: API.upload(),
        files: [MultipartFileModel(file: file, name: 'file')],
        showError: false,
      ).post();
}
```

### API Endpoints

```dart
// lib/data/network/api/api.dart
class API {
  static String get server => Globals.config.server ?? '';
  static int get successCode => 0;

  static myEndpoint() => 'api/my-feature/action';
  static upload() => 'api/shared/upload';
}
```

---

## 5. Navigation

```dart
// Push screen mới
CustomNavigator.push(context, MyScreen());

// Push và lấy kết quả
final result = await CustomNavigator.push(context, MyScreen());
if (result == true) { /* refresh */ }

// Pop với kết quả
CustomNavigator.pop(context, object: true);

// Replace screen hiện tại
CustomNavigator.pushReplacement(context, NewScreen());

// Mở bottom sheet
final result = await CustomDialog.showBottom(
  context,
  CustomBottomSheet(
    title: 'Tiêu đề',
    body: MyWidget(),
  ),
);

// Alert dialog
CustomDialog.showAlert(
  context,
  'Nội dung thông báo',
  title: 'Tiêu đề',
  type: CustomAlertDialogType.warning,  // success | error | warning | info
);

// Loading overlay
CustomLoading.show(context);
await doWork();
CustomLoading.hide();
```

---

## 6. Localization

```dart
// Đọc string
LangKey.current.my_key

// Thêm key mới — 3 nơi cần sửa:

// 1. lib/common/localization/l10n.dart
/// `Tên hiển thị`
String get my_key {
  return Intl.message('Tên hiển thị', name: 'my_key', desc: '', args: []);
}

// 2. lib/common/localization/intl/messages_vi.dart
"my_key": MessageLookupByLibrary.simpleMessage("Tên tiếng Việt"),

// 3. lib/common/localization/intl/messages_en.dart
"my_key": MessageLookupByLibrary.simpleMessage("English Name"),
```

---

## 7. Theme & Styling

```dart
// Màu sắc
AppColors.primary      // Màu chính
AppColors.red          // Đỏ (xóa, lỗi)
AppColors.green        // Xanh lá (thành công)
AppColors.white
AppColors.grey
AppColors.hint
AppColors.line

// Kích thước
AppSizes.minPadding    // padding nhỏ (~8)
AppSizes.maxPadding    // padding lớn (~16)
AppSizes.minBorderRadius
AppSizes.icon

// Typography
AppTextStyle.body16W600.textStyle
AppTextStyle.subBody14W500.textStyle
AppTextStyle.body16Bold.textStyle
AppTextStyle.tiny12W500.textStyle

// Font size
AppTextSizes.body      // 16
AppTextSizes.subBody   // 14
AppTextSizes.title     // 18+

// Format ngày
AppFormat.date         // DateFormat("dd/MM/yyyy")
AppFormat.dateRequest  // DateFormat("yyyy-MM-dd")
AppFormat.dateResponse // DateFormat("yyyy-MM-dd HH:mm:ss")

CustomAppFormat.formatDate(dateTime)              // → "dd/MM/yyyy"
CustomAppFormat.parseAndFormatDate(str, parse: AppFormat.date, format: AppFormat.dateRequest)
CustomAppFormat.formatValue(value)                // null → "--"
```

---

## 8. Widget Library

Tất cả widget tái sử dụng nằm trong `lib/presentation/widget/`. Import bằng:

```dart
import 'package:wasucowork/presentation/widget/widget.dart';
```

### Widget thường dùng

| Widget | Dùng khi |
|---|---|
| `CustomScaffold` | Scaffold chuẩn của app (title, body, appbar) |
| `CustomText` | Text có style — thay `Text()` |
| `CustomButton` | Nút bấm có màu + loading |
| `CustomTextField` | Input field có style chuẩn |
| `CustomListView` | ListView với separator, padding |
| `CustomColumnInformation` | Hàng label + value thông tin |
| `CustomBlockTag` | Container có màu nền/border |
| `CustomTabBar` | Tab bar có animation |
| `CustomBottomSheet` | Bottom sheet chuẩn có title |

### Widgets đặc thù feature

Các widget phức tạp gắn với 1 feature thì đặt trong `container_[feature].dart`:

```dart
// Ví dụ: container_update_meter_reading.dart
part of widget;

class UpdateMeterReadingMeterInfo extends StatelessWidget { ... }
class UpdateMeterReadingMaterial extends StatelessWidget { ... }
class UpdateMeterReadingNote extends StatelessWidget { ... }
```

---

## 9. Globals

```dart
// lib/common/globals.dart
Globals.prefs          // SharedPrefs — local storage
Globals.config         // Config — cấu hình từ config.json
Globals.config.versionName    // version hiển thị (lấy từ config.json, KHÔNG phải pubspec)
Globals.config.server         // base URL
Globals.locale         // Locale hiện tại
Globals.model          // LoginResModel — thông tin user đăng nhập
Globals.bloc           // MainBloc — bloc màn hình chính
```

---

## 10. Checklist refactor 1 feature

Với mỗi feature mới cần tạo:

```
✅ Data layer
   □ models/request/[feature]_req_model.dart        (toJson)
   □ models/response/[feature]_res_model.dart        (fromJson)
   □ api.dart — thêm endpoint static method
   □ repository.dart — thêm static method gọi Interaction

✅ Presentation layer
   □ presentation/module/.../[feature]/
       ├── bloc/[feature]_bloc.dart   (extends BaseBloc<FeatureScreen>)
       └── ui/[feature]_screen.dart   (extends BaseView)

✅ Localization
   □ l10n.dart — thêm String get key
   □ messages_vi.dart — thêm bản dịch VI
   □ messages_en.dart — thêm bản dịch EN

✅ Bloc checklist
   □ Khai báo BehaviorSubject cho từng state
   □ Dispose tất cả subject trong onDispose()
   □ Dispose tất cả TextEditingController, FocusNode
   □ Fetch API trong onReady() (không phải onInit())
   □ Dùng CustomLoading.show/hide cho async action
   □ Dùng CustomDialog.showAlert cho lỗi validation
```

---

## 11. Ví dụ hoàn chỉnh — Feature đơn giản

### Yêu cầu: màn hình danh sách + gọi API

**`my_list_req_model.dart`**
```dart
class MyListReqModel {
  final int page;
  MyListReqModel({this.page = 1});
  Map<String, dynamic> toJson() => {'page': page, 'page_size': 20};
}
```

**`my_list_res_model.dart`**
```dart
class MyListResModel {
  final List<MyItemModel>? items;
  MyListResModel({this.items});
  factory MyListResModel.fromJson(Map<String, dynamic> json) => MyListResModel(
    items: (json['items'] as List?)?.map((e) => MyItemModel.fromJson(e)).toList(),
  );
}
class MyItemModel {
  final String? id, name;
  MyItemModel({this.id, this.name});
  factory MyItemModel.fromJson(Map<String, dynamic> json) =>
      MyItemModel(id: json['id']?.toString(), name: json['name']);
}
```

**`api.dart`** — thêm:
```dart
static myList() => 'api/my-feature/list';
```

**`repository.dart`** — thêm:
```dart
static myList(BuildContext context, MyListReqModel model) =>
    Interaction(context: context, url: API.myList(), param: model.toJson()).post();
```

**`my_list_bloc.dart`**
```dart
class MyListBloc extends BaseBloc<MyListScreen> {
  final streamItems = BehaviorSubject<List<MyItemModel>?>();

  @override void onInit() {}

  @override void onReady() { _fetch(); }

  @override void onResumed() {}

  @override void onDispose() { streamItems.close(); }

  _fetch() async {
    streamItems.set(null);  // trigger loading state
    final res = await Repository.myList(context, MyListReqModel());
    if (res.success) {
      streamItems.set(MyListResModel.fromJson(res.data).items ?? []);
    } else {
      streamItems.set([]);
    }
  }

  onTapItem(MyItemModel item) {
    CustomNavigator.push(widget.context, MyDetailScreen(item));
  }
}
```

**`my_list_screen.dart`**
```dart
class MyListScreen extends BaseView {
  final MyListBloc _bloc = MyListBloc();

  @override MyListBloc createState() => _bloc;

  @override Widget build(BuildContext context) {
    return CustomScaffold(
      title: LangKey.current.my_title,
      body: StreamBuilder<List<MyItemModel>?>(
        stream: _bloc.streamItems,
        builder: (context, snapshot) {
          final items = snapshot.data;
          if (items == null) return const Center(child: CircularProgressIndicator());
          if (items.isEmpty) return Center(child: CustomText(text: LangKey.current.data_empty));
          return CustomListView(
            children: items.map((item) => _buildItem(item)).toList(),
          );
        },
      ),
    );
  }

  Widget _buildItem(MyItemModel item) {
    return CustomInkWell(
      onTap: () => _bloc.onTapItem(item),
      child: CustomColumnInformation(
        title: 'Tên',
        content: item.name,
      ),
    );
  }
}
```
