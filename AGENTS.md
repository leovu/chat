# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter Chat Plugin providing real-time messaging, group chat, file sharing, and ChatHub integration. It supports Android, iOS, and Web platforms.

## Common Commands

```bash
# Dependencies
flutter pub get                    # Install dependencies
flutter pub upgrade               # Upgrade dependencies

# Development
flutter run                        # Run in development mode
flutter run -d chrome             # Run on web

# Build
flutter build apk                 # Build Android APK
flutter build ios                 # Build iOS app
flutter build web                 # Build web version

# Testing and Analysis
flutter test                       # Run unit tests
flutter analyze                    # Analyze code
dart format .                      # Format code
```

## Architecture

The codebase follows a layered architecture with BLoC state management:

### Layer Structure

1. **Presentation Layer** (`lib/presentation/`)
   - `chat_module/bloc/` - BLoC state management using RxDart
   - `chat_module/ui/` - UI screens and widgets
   - `utils/` - UI helpers (dialogs, formatters)

2. **Data Layer** (`lib/data_model/`)
   - Core models: `ChatMessage`, `Room`, `User`, `Contact`
   - `request/` and `response/` subdirectories for API models

3. **Connection Layer** (`lib/connection/`)
   - `chat_connection.dart` - Main connection manager (singleton)
   - `http_connection.dart` - REST API client using Dio
   - `socket.dart` - WebSocket handler using socket_io_client

4. **UI Components** (`lib/chat_ui/`)
   - `chat_theme.dart` - Theme configuration
   - `widgets/` - Reusable chat components
   - `chat_l10n.dart` - Localization

5. **Screens** (`lib/chat_screen/`)
   - 20+ screen implementations (home, room list, contacts, search, etc.)

### Key Entry Points

- **`lib/chat.dart`** - Main plugin entry point with `Chat.open()`, `Chat.connectSocket()`, `Chat.disconnectSocket()`
- **`lib/connection/chat_connection.dart`** - Static singleton managing authentication, sockets, and HTTP
- **`lib/presentation/chat_module/bloc/chat_bloc.dart`** - Main BLoC for chat state

### State Management Pattern

Uses RxDart with BehaviorSubject streams. The `BaseBloc` abstract class in `lib/common/base_bloc.dart` provides shared functionality for all BLoCs.

## Platform Configuration

### Android
- compileSdkVersion: 34
- minSdkVersion: 23
- Kotlin: 1.8.0
- Platform channel: `android/src/main/kotlin/.../ChatPlugin.kt`

### iOS
- Minimum iOS: 10.0
- Swift implementation: `ios/Classes/ChatPlugin.swift`
- Uses embedded views preview

## Localization

Supports English and Vietnamese. Language files are in `assets/chat_en.json` and `assets/chat_vi.json`. Language keys defined in `lib/localization/lang_key.dart`.

## Key Dependencies

- **socket_io_client** (1.0.2) - WebSocket communication
- **dio** (5.8.0) - HTTP client
- **rxdart** (0.28.0) - Reactive state management
- **flutter_chat_types** (3.6.2) - Message type definitions
- **audioplayers**, **video_player** - Media playback
- **image_picker**, **file_picker** - Media selection

## Add-on Module System

The ChatConnection class integrates optional CRM modules (products, orders, appointments, deals, tasks, customers) through the `addOnModules` property for extending functionality.


# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## Project Overview

WASUCO is a Flutter mobile application for water billing management (Nha Be Water Supply Company). The app handles debt collection, water cutoff/reopen management, meter reading, customer data, invoices, and reporting.

## Build Commands

```bash
# Interactive build tool (selects environment and build action)
dart build_app.dart

# Generate localization keys (after modifying .arb files)
flutter pub run intl_utils:generate

# Generate asset keys (or use Alt+G in Android Studio)
# Build => Generate Flutter Assets

# Standard Flutter commands
flutter pub get
flutter run --release
flutter build apk --release --no-tree-shake-icons
flutter build appbundle --release --no-tree-shake-icons
flutter build ios --no-tree-shake-icons
```

## Architecture

### Layer Structure
- `lib/common/` - Shared utilities, theme, config, globals, localization
- `lib/data/` - Data layer (models, network, local storage)
- `lib/domain/` - Business logic (Repository, Interaction)
- `lib/presentation/` - UI layer (screens, blocs, widgets)
- `lib/sqlite/` - Local SQLite database helpers for offline meter reading

### BaseView/BaseBloc Pattern
All screens extend `BaseView` and their state extends `BaseBloc<T>`. This pattern provides lifecycle hooks:
```dart
class MyScreen extends BaseView {
  final MyBloc _bloc = MyBloc();
  @override MyBloc createState() => _bloc;
  @override Widget build(BuildContext context) { ... }
}

class MyBloc extends BaseBloc<MyScreen> {
  void onInit() { }    // Called in initState
  void onReady() { }   // Called after first frame
  void onResumed() { } // Called when app resumes
  void onDispose() { } // Called on dispose
}
```

### Network Layer
- `Repository` (`lib/domain/repository.dart`) - Static methods for all API calls
- `Interaction` (`lib/domain/interaction/`) - HTTP wrapper extending `HttpConnection`, handles auth token refresh (401)
- `API` (`lib/data/network/api/`) - API endpoint definitions
- Response wrapper: `ResponseModel` with `success`, `data`, `errorMessage`, `errorCode`

### State Management
Uses `rxdart` BehaviorSubject with custom extensions:
```dart
// Set value and optionally trigger callback
behaviorSubject.set(newValue, function: () => doSomething());
// Access stream for StreamBuilder
behaviorSubject.output
```

### Module Structure
Screens organized as modules under `presentation/modules/`:
```
main_module/
  modules/
    home_module/
      modules/
        debt_module/src/bloc/ + ui/
        close_module/src/bloc/ + ui/
        open_module/src/bloc/ + ui/
        meter_reading/modules/...
```

### Widget Library
`lib/presentation/widgets/widget.dart` is a library file that exports all custom widgets via `part` directives. Custom widgets include: CustomText, CustomButton, CustomScaffold, CustomTextField, CustomBottomSheet, CustomDialog, etc.

## Key Conventions

- Use `CustomText` instead of `Text` widget
- Access screen dimensions via context extensions: `context.width`, `context.height`, `context.padding`
- Localization: `LangKey.current.keyName` (Vietnamese is main locale)
- Assets: `Assets.keyName` (auto-generated)
- Global state stored in `Globals` class (prefs, config, models, bloc)
- Theme constants in `AppColors`, `AppSizes`, `AppTextStyle`, `AppFormat`
- Safe parsing via extension: `value.toInt`, `value.toDouble`, `value.toBool`, `value.toSafeString`

## Configuration

Environment config stored in `assets/json/config.json`. The `build_app.dart` script handles environment selection (DEV/STAG/PRODUCT_TEST/PRODUCT) and updates the config before building.

## Key Files Reference

- `lib/common/globals.dart` - Global state container (prefs, config, user model, permissions)
- `lib/common/theme.dart` - AppColors, AppSizes, AppTextStyle definitions
- `lib/common/utilities.dart` - Helper methods (navigation, pickers, API helpers, location, bluetooth)
- `lib/common/constant.dart` - App constants, enums, predefined lists (meter reading codes, etc.)
- `lib/presentation/base/base_view.dart` - BaseView/BaseBloc classes, context extensions
