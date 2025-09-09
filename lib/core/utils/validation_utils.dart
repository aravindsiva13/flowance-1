
// lib/core/utils/validation_utils.dart

class ValidationUtils {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,});
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }
  
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }
    
    return null;
  }
  
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  static String? validateProjectName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Project name is required';
    }
    
    if (value.length < 3) {
      return 'Project name must be at least 3 characters';
    }
    
    if (value.length > 100) {
      return 'Project name must be less than 100 characters';
    }
    
    return null;
  }
  
  static String? validateTaskTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Task title is required';
    }
    
    if (value.length < 3) {
      return 'Task title must be at least 3 characters';
    }
    
    if (value.length > 200) {
      return 'Task title must be less than 200 characters';
    }
    
    return null;
  }
  
  static String? validateDescription(String? value, {bool required = false}) {
    if (required && (value == null || value.trim().isEmpty)) {
      return 'Description is required';
    }
    
    if (value != null && value.length > 1000) {
      return 'Description must be less than 1000 characters';
    }
    
    return null;
  }
  
  static String? validateUrl(String? value, {bool required = false}) {
    if (!required && (value == null || value.isEmpty)) {
      return null;
    }
    
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }
    
    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return 'Please enter a valid URL';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid URL';
    }
  }
  
  static bool isValidDate(String? value) {
    if (value == null || value.isEmpty) return false;
    try {
      DateTime.parse(value);
      return true;
    } catch (e) {
      return false;
    }
  }
}
