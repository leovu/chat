# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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
