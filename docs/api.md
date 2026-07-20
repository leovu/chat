# API Documentation — chat

## Base URL
```
Production:  https://api.example.com/v1
Staging:     https://staging-api.example.com/v1
```

## Authentication
```
Header: Authorization: Bearer <token>
```

## Endpoints

### Auth
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /auth/login | Đăng nhập |
| POST | /auth/logout | Đăng xuất |
| POST | /auth/refresh | Refresh token |

### [Feature Name]
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /resource | Lấy danh sách |
| GET | /resource/:id | Lấy chi tiết |
| POST | /resource | Tạo mới |
| PUT | /resource/:id | Cập nhật |
| DELETE | /resource/:id | Xóa |

## Error Codes
| Code | Message | Xử lý |
|------|---------|-------|
| 400 | Bad Request | Kiểm tra input |
| 401 | Unauthorized | Refresh token |
| 403 | Forbidden | Không có quyền |
| 404 | Not Found | Hiển thị empty state |
| 500 | Server Error | Retry hoặc contact support |
