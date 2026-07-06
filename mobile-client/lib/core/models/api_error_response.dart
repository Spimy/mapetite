class ApiErrorResponse {
  final String? detail;
  final Map<String, List<String>> fieldErrors;

  const ApiErrorResponse({this.detail, this.fieldErrors = const {}});

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    final fieldErrors = <String, List<String>>{};
    String? detail;

    json.forEach((key, value) {
      if (key == 'detail' && value is String) {
        detail = value;
      } else if (value is List) {
        fieldErrors[key] = List<String>.from(value.map((e) => e.toString()));
      } else if (value is String) {
        fieldErrors[key] = [value];
      }
    });

    return ApiErrorResponse(detail: detail, fieldErrors: fieldErrors);
  }

  /// Instantly grabs the most relevant error message for the UI
  String get displayMessage {
    return detail ??
        fieldErrors.values.expand((e) => e).firstOrNull ??
        'Something went wrong. Please check your inputs.';
  }
}
