import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ErrorHandler {
  ErrorHandler._();

  /// Translates Firebase Auth error codes to user-friendly Uzbek messages
  static String getAuthErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Bunday email mavjud emas.';
        case 'wrong-password':
          return 'Parol noto\'g\'ri.';
        case 'invalid-email':
          return 'Email formati noto\'g\'ri.';
        case 'email-already-in-use':
          return 'Bu email allaqachon ro\'yxatdan o\'tgan.';
        case 'weak-password':
          return 'Parol juda oddiy. Kamida 6 ta belgi kiriting.';
        case 'too-many-requests':
          return 'Juda ko\'p urinishlar. Biroz kuting.';
        case 'user-disabled':
          return 'Bu hisob bloklangan.';
        case 'operation-not-allowed':
          return 'Bu amal taqiqlangan.';
        case 'network-request-failed':
          return 'Internet aloqasi yo\'q. Qaytadan urinib ko\'ring.';
        default:
          return 'Xatolik yuz berdi: ${error.message}';
      }
    }
    return 'Kutilmagan xatolik yuz berdi. Qaytadan urinib ko\'ring.';
  }

  /// Shows a styled error SnackBar
  static void showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Shows a styled success SnackBar
  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Shows an info SnackBar
  static void showInfo(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
