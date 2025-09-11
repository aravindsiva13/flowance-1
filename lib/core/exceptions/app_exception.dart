
// lib/core/exceptions/app_exception.dart

class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;
  
  const AppException(this.message, {this.code, this.details});
  
  @override
  String toString() {
    return 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

class ApiException extends AppException {
  final int? statusCode;
  
  const ApiException(String message, {this.statusCode, String? code, dynamic details})
      : super(message, code: code, details: details);
  
  @override
  String toString() {
    return 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }
}

class NetworkException extends AppException {
  const NetworkException([String message = 'Network error occurred']) : super(message);
}

class AuthenticationException extends AppException {
  const AuthenticationException([String message = 'Authentication failed']) : super(message);
}

class PermissionException extends AppException {
  const PermissionException([String message = 'Permission denied']) : super(message);
}

class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;
  
  const ValidationException(String message, {this.fieldErrors}) : super(message);
}

class NotFoundException extends AppException {
  const NotFoundException([String message = 'Resource not found']) : super(message);
}