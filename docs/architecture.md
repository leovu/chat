# Architecture — chat

## Cấu trúc thư mục

```
lib/
├── core/
│   ├── theme/          # ThemeData, colors, text styles
│   ├── constants/      # App constants, route names
│   ├── errors/         # Failure classes, exceptions
│   ├── network/        # Dio client, interceptors
│   └── utils/          # Helpers, extensions
│
├── features/
│   └── <feature>/
│       ├── presentation/
│       │   ├── pages/
│       │   ├── widgets/
│       │   └── bloc/
│       ├── domain/
│       │   ├── entities/
│       │   └── use_cases/
│       └── data/
│           ├── models/
│           ├── repositories/
│           └── data_sources/
│
└── main.dart
```

## State Management
> [BLoC / Cubit / Provider / Riverpod] — cập nhật cho dự án này

## Navigation
> [GoRouter / Navigator 2.0 / GetX] — cập nhật cho dự án này

## Dependency Injection
> [GetIt / Injectable / Provider] — cập nhật cho dự án này

## Key Packages
> Liệt kê packages chính từ pubspec.yaml

## Data Flow

```
UI → Cubit/BLoC → UseCase → Repository → DataSource → API
                                       ↓
                                   Local DB (nếu có)
```

## Conventions
- File names: `snake_case.dart`
- Class names: `PascalCase`
- Constants: `kConstantName`
- Private fields: `_fieldName`
