class BaseResponse<T> {
  final int? error;
  final T? data;
  final String? message;

  BaseResponse({this.error, this.data, this.message});

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) create,
  ) {
    return BaseResponse<T>(
      error: json['error'],
      data: json['data'] != null && json['error'] == 0
          ? create(json['data'])
          : null,
      message: json['error'] != 0 ? json['message'] ?? 'Unknown error' : null,
    );
  }
}
