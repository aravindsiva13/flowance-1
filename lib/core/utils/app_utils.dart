
// // lib/core/utils/app_utils.dart

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:csv/csv.dart';

// class AppUtils {
//   static void showSnackBar(BuildContext context, String message, {Color? backgroundColor}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: backgroundColor,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         borderRadius: BorderRadius.circular(8),
//       ),
//     );
//   }
  
//   static void showSuccessSnackBar(BuildContext context, String message) {
//     showSnackBar(context, message, backgroundColor: Colors.green);
//   }
  
//   static void showErrorSnackBar(BuildContext context, String message) {
//     showSnackBar(context, message, backgroundColor: Colors.red);
//   }
  
//   static Future<bool> showConfirmDialog(
//     BuildContext context, {
//     required String title,
//     required String content,
//     String confirmText = 'Confirm',
//     String cancelText = 'Cancel',
//   }) async {
//     return await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(title),
//         content: Text(content),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: Text(cancelText),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: Text(confirmText),
//           ),
//         ],
//       ),
//     ) ?? false;
//   }
  
//   static void showLoadingDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => const Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
  
//   static void hideLoadingDialog(BuildContext context) {
//     Navigator.of(context).pop();
//   }
  
//   static String truncateText(String text, int maxLength) {
//     if (text.length <= maxLength) return text;
//     return '${text.substring(0, maxLength)}...';
//   }
  
//   static String capitalize(String text) {
//     if (text.isEmpty) return text;
//     return text[0].toUpperCase() + text.substring(1).toLowerCase();
//   }
  
//   static String capitalizeWords(String text) {
//     return text.split(' ').map((word) => capitalize(word)).join(' ');
//   }
  
//   static Color getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'todo':
//       case 'to do':
//         return Colors.grey;
//       case 'inprogress':
//       case 'in progress':
//         return Colors.blue;
//       case 'inreview':
//       case 'in review':
//         return Colors.orange;
//       case 'done':
//       case 'completed':
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }
  
//   static Color getPriorityColor(String priority) {
//     switch (priority.toLowerCase()) {
//       case 'low':
//         return Colors.green;
//       case 'medium':
//         return Colors.orange;
//       case 'high':
//         return Colors.red;
//       case 'urgent':
//         return Colors.deepOrange;
//       default:
//         return Colors.grey;
//     }
//   }
  
//   static String formatProgress(double progress) {
//     return '${(progress * 100).toInt()}%';
//   }
  
//   static String formatFileSize(int bytes) {
//     if (bytes <= 0) return '0 B';
//     const suffixes = ['B', 'KB', 'MB', 'GB'];
//     var i = 0;
//     double size = bytes.toDouble();
//     while (size > 1024 && i < suffixes.length - 1) {
//       size /= 1024;
//       i++;
//     }
//     return '${size.toStringAsFixed(1)} ${suffixes[i]}';
//   }
  
//   static String generateCSV(List<Map<String, dynamic>> data) {
//     if (data.isEmpty) return '';
    
//     final headers = data.first.keys.toList();
//     final rows = data.map((row) => headers.map((header) => row[header]?.toString() ?? '').toList()).toList();
    
//     return const ListToCsvConverter().convert([headers, ...rows]);
//   }
  
//   static Map<String, dynamic> parseJsonSafely(String jsonString) {
//     try {
//       return json.decode(jsonString) as Map<String, dynamic>;
//     } catch (e) {
//       return {};
//     }
//   }
  
//   static String encodeJson(Map<String, dynamic> data) {
//     try {
//       return json.encode(data);
//     } catch (e) {
//       return '{}';
//     }
//   }
  
//   static bool isTablet(BuildContext context) {
//     final mediaQuery = MediaQuery.of(context);
//     return mediaQuery.size.shortestSide >= 600;
//   }
  
//   static bool isMobile(BuildContext context) {
//     return !isTablet(context);
//   }
  
//   static double getResponsiveWidth(BuildContext context, {double mobile = 1.0, double tablet = 0.7}) {
//     return isTablet(context) ? tablet : mobile;
//   }
// }



//2



// lib/core/utils/app_utils.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';

class AppUtils {
  static void showSnackBar(BuildContext context, String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.green);
  }
  
  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.red);
  }
  
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    ) ?? false;
  }
  
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
  
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }
  
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'todo':
      case 'to do':
        return Colors.grey;
      case 'inprogress':
      case 'in progress':
        return Colors.blue;
      case 'inreview':
      case 'in review':
        return Colors.orange;
      case 'done':
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'urgent':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }
  
  static String formatProgress(double progress) {
    return '${(progress * 100).toInt()}%';
  }
  
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();
    while (size > 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }
  
  static String generateCSV(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return '';
    
    final headers = data.first.keys.toList();
    final rows = data.map((row) => headers.map((header) => row[header]?.toString() ?? '').toList()).toList();
    
    return const ListToCsvConverter().convert([headers, ...rows]);
  }
  
  static Map<String, dynamic> parseJsonSafely(String jsonString) {
    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }
  
  static String encodeJson(Map<String, dynamic> data) {
    try {
      return json.encode(data);
    } catch (e) {
      return '{}';
    }
  }
  
  static bool isTablet(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.shortestSide >= 600;
  }
  
  static bool isMobile(BuildContext context) {
    return !isTablet(context);
  }
  
  static double getResponsiveWidth(BuildContext context, {double mobile = 1.0, double tablet = 0.7}) {
    return isTablet(context) ? tablet : mobile;
  }
}