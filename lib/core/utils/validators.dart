class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Emailni kiriting';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email formati noto\'g\'ri';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Parolni kiriting';
    }
    if (value.length < 6) {
      return 'Parol kamida 6 ta belgidan iborat bo\'lishi kerak';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Parolni tasdiqlang';
    }
    if (value != password) {
      return 'Parollar mos kelmaydi';
    }
    return null;
  }

  static String? required(String? value, [String fieldName = 'Maydon']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName to\'ldirilishi shart';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ismingizni kiriting';
    }
    if (value.trim().length < 2) {
      return 'Ism kamida 2 ta belgidan iborat bo\'lishi kerak';
    }
    return null;
  }
}
