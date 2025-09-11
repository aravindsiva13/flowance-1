
// =================================================================

// lib/core/exceptions/api_exception.dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final dynamic details;
  
  const ApiException(
    this.message, {
    this.statusCode,
    this.code,
    this.details,
  });
  
  @override
  String toString() {
    return 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }

  factory ApiException.fromResponse(int statusCode, String message) {
    switch (statusCode) {
      case 400:
        return ApiException(message, statusCode: statusCode, code: 'BAD_REQUEST');
      case 401:
        return ApiException(message, statusCode: statusCode, code: 'UNAUTHORIZED');
      case 403:
        return ApiException(message, statusCode: statusCode, code: 'FORBIDDEN');
      case 404:
        return ApiException(message, statusCode: statusCode, code: 'NOT_FOUND');
      case 500:
        return ApiException(message, statusCode: statusCode, code: 'INTERNAL_SERVER_ERROR');
      default:
        return ApiException(message, statusCode: statusCode, code: 'UNKNOWN');
    }
  }
}

class NetworkException extends ApiException {
  const NetworkException([String message = 'Network error occurred']) 
      : super(message, code: 'NETWORK_ERROR');
}

class AuthenticationException extends ApiException {
  const AuthenticationException([String message = 'Authentication failed']) 
      : super(message, statusCode: 401, code: 'AUTH_ERROR');
}

class PermissionException extends ApiException {
  const PermissionException([String message = 'Permission denied']) 
      : super(message, statusCode: 403, code: 'PERMISSION_DENIED');
}

class ValidationException extends ApiException {
  final Map<String, String>? fieldErrors;
  
  const ValidationException(String message, {this.fieldErrors}) 
      : super(message, statusCode: 400, code: 'VALIDATION_ERROR');
}

class NotFoundException extends ApiException {
  const NotFoundException([String message = 'Resource not found']) 
      : super(message, statusCode: 404, code: 'NOT_FOUND');
}
