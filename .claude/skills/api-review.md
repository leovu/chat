# API Layer Review Skill

Review API layer (models, repositories, data sources) trong Flutter project.

---

## 1. Model Review
- `fromJson` / `toJson` đầy đủ và đúng types
- Nullable fields được xử lý (`??` default values)
- `copyWith` method có
- Không dùng `dynamic` nếu có thể tránh
- Dùng `freezed` nếu project đã setup

## 2. Repository Interface
- Methods trả về `Future<Either<Failure, T>>`
- Abstract, không phụ thuộc implementation
- Tên method rõ ràng: `getUser`, `createOrder`, `updateProfile`

## 3. Data Source
- Handle HTTP status codes (401, 403, 404, 500...)
- Throw typed exceptions (ServerException, NetworkException)
- Không return null — throw exception hoặc return empty
- Timeout được set
- Logging request/response (chỉ trong debug mode)

## 4. Repository Implementation
- Catch exceptions → convert → Left(Failure)
- Happy path → Right(data)
- Cache strategy rõ ràng (nếu có)
- Offline handling

## 5. Error Handling
- Custom Failure classes có message
- Error propagation lên đến UI
- User-friendly error messages

## Checklist
- [ ] Không có hardcoded base URL
- [ ] API keys qua environment variables
- [ ] Retry logic cho network errors
- [ ] Response caching khi phù hợp
- [ ] Unit tests cho repository (mock data source)

## Output
Liệt kê issues theo file, với mức độ: 🔴 Critical / 🟡 Warning / 🟢 Suggestion
