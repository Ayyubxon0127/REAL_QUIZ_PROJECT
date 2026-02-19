import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // Brand Colors
  static const Color primaryColor = Color(0xFF1A237E);
  static const Color secondaryColor = Color(0xFF3949AB);
  static const Color accentColor = Color(0xFF00BCD4);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF2E7D32);
  static const Color warningColor = Color(0xFFF57C00);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXL = 24.0;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String quizzesCollection = 'quizzes';
  static const String scoresCollection = 'scores';

  // Roles
  static const String roleAdmin = 'admin';
  static const String roleUser = 'user';

  // App Info
  static const String appName = 'QuizMaster';
  static const String appVersion = '2.0.0';

  // Shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: primaryColor.withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}
