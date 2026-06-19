# API: $ARGUMENTS

Tạo API layer (model + repository + data source) cho $ARGUMENTS.

## Quy trình

1. **Đọc docs/api.md** để hiểu API endpoints hiện có
2. **Tạo Model** (`lib/data/models/<name>_model.dart`):
   - `fromJson()` factory constructor
   - `toJson()` method
   - `copyWith()` method
   - Sử dụng `freezed` nếu project đang dùng
3. **Tạo Repository interface** (`lib/domain/repositories/<name>_repository.dart`):
   - Abstract class với các methods trả về `Future<Either<Failure, T>>`
4. **Tạo Data Source** (`lib/data/data_sources/<name>_remote_data_source.dart`):
   - Gọi HTTP client (Dio/http)
   - Handle errors và throw custom exceptions
5. **Implement Repository** (`lib/data/repositories/<name>_repository_impl.dart`):
   - Convert exceptions → Failures
   - Handle offline/cache nếu cần
6. **Register** vào dependency injection
7. **Viết unit test** cho repository
8. **Cập nhật** `docs/api.md` với endpoint mới

## Error Handling Pattern
```dart
try {
  final result = await remoteDataSource.fetchData();
  return Right(result);
} on ServerException catch (e) {
  return Left(ServerFailure(e.message));
} on NetworkException {
  return Left(NetworkFailure());
}
```
