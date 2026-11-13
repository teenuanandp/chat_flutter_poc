
class ApiResponse<T> {
  final int statusCode;
  final bool success;
  final String message;
  final T? data;
  final String? errorCode;

  const ApiResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromData,
  ) {
    final responseData = json['data'];

    return ApiResponse<T>(
      statusCode: json['statusCode'] as int? ?? 0,
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: responseData == null ? null : fromData(responseData),
      errorCode: json['errorCode'] as String?,
    );
  }
}