# Test Generator Skill

Sinh test tự động cho Flutter code hiện có.

## Nhận vào
File path hoặc class name cần generate tests.

## Quy trình

### 1. Phân tích code
- Đọc file target, xác định: class type (Cubit, Repository, Widget, UseCase, Model)
- List tất cả public methods / states cần test
- Xác định dependencies cần mock

### 2. Chọn test type
| Type | Dùng cho | Framework |
|------|----------|-----------|
| Unit test | UseCase, Repository, Model | `flutter_test` + `mocktail` |
| Bloc test | Cubit, BLoC | `bloc_test` |
| Widget test | Widgets, Pages | `flutter_test` + `pump` |
| Golden test | UI regression | `golden_toolkit` |

### 3. Template Unit Test
```dart
group('ClassName', () {
  late ClassName sut;
  late MockDependency mockDep;

  setUp(() {
    mockDep = MockDependency();
    sut = ClassName(mockDep);
  });

  group('methodName', () {
    test('should return X when Y', () async {
      // Arrange
      when(() => mockDep.call()).thenReturn(value);
      // Act
      final result = await sut.methodName();
      // Assert
      expect(result, equals(expected));
    });

    test('should throw Failure when error occurs', () async {
      // Arrange
      when(() => mockDep.call()).thenThrow(ServerException());
      // Act & Assert
      expect(() => sut.methodName(), throwsA(isA<ServerFailure>()));
    });
  });
});
```

### 4. Template Bloc Test
```dart
blocTest<MyCubit, MyState>(
  'emits [loading, success] when fetch succeeds',
  build: () {
    when(() => mockUseCase.call()).thenAnswer((_) async => Right(data));
    return MyCubit(mockUseCase);
  },
  act: (cubit) => cubit.fetch(),
  expect: () => [MyLoadingState(), MySuccessState(data)],
);
```

### 5. Quy tắc đặt tên
- `should_<expected>_when_<condition>`
- Ví dụ: `should_emit_error_when_network_fails`

## Output
Tạo file `test/<path>/<filename>_test.dart` với full test coverage.
