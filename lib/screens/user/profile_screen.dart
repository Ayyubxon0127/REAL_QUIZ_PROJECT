import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/error_handler.dart';
import '../../core/utils/validators.dart';
import '../../services/auth_service.dart';
import '../../models/app_user_model.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<AppUser?>(
        stream: _authService.currentAppUserStream(),
        builder: (context, snapshot) {
          final user = snapshot.data;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 8),

                // Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppConstants.primaryColor,
                        AppConstants.secondaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                        ),
                        child: Center(
                          child: Text(
                            (user?.name.isNotEmpty == true)
                                ? user!.name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.name ?? 'Foydalanuvchi',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stats row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildProfileStat('Quiz', '${user?.quizzesTaken ?? 0}'),
                          Container(
                            width: 1,
                            height: 30,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          _buildProfileStat('Ball', '${user?.totalScore ?? 0}'),
                          Container(
                            width: 1,
                            height: 30,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          _buildProfileStat(
                            'O\'rtacha',
                            '${user?.averageScore.toStringAsFixed(1) ?? '0'}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Settings Section
                _buildSectionTitle('Sozlamalar'),
                const SizedBox(height: 12),

                _buildSettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Parolni o\'zgartirish',
                  onTap: () => _showChangePasswordDialog(context),
                ),
                _buildSettingsTile(
                  icon: Icons.info_outline,
                  title: 'Ilova haqida',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: AppConstants.appName,
                      applicationVersion: AppConstants.appVersion,
                      applicationIcon: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.quiz, color: Colors.white),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Logout
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text('Chiqish'),
                          content: const Text('Hisobdan chiqmoqchimisiz?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Yo\'q'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.errorColor,
                              ),
                              child: const Text('Ha, chiqish'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await _authService.signOut();
                      }
                    },
                    icon: const Icon(Icons.logout, color: AppConstants.errorColor),
                    label: const Text(
                      'Hisobdan chiqish',
                      style: TextStyle(color: AppConstants.errorColor),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppConstants.errorColor.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  '${AppConstants.appName} v${AppConstants.appVersion}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade500,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: AppConstants.cardShadow,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppConstants.primaryColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Parolni o\'zgartirish'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentPassCtrl,
                  obscureText: true,
                  validator: Validators.password,
                  decoration: const InputDecoration(
                    labelText: 'Hozirgi parol',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newPassCtrl,
                  obscureText: true,
                  validator: Validators.password,
                  decoration: const InputDecoration(
                    labelText: 'Yangi parol',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Bekor qilish'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isLoading = true);
                      try {
                        await _authService.changePassword(
                          currentPassword: currentPassCtrl.text,
                          newPassword: newPassCtrl.text,
                        );
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ErrorHandler.showSuccess(
                            context,
                            'Parol muvaffaqiyatli o\'zgartirildi',
                          );
                        }
                      } catch (e) {
                        if (ctx.mounted) {
                          ErrorHandler.showError(
                            context,
                            ErrorHandler.getAuthErrorMessage(e),
                          );
                        }
                      } finally {
                        setDialogState(() => isLoading = false);
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Saqlash'),
            ),
          ],
        ),
      ),
    );
  }
}
