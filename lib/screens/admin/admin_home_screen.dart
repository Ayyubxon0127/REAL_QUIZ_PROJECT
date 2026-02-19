import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/error_handler.dart';
import '../../services/auth_service.dart';
import '../../services/quiz_service.dart';
import '../../models/quiz_model.dart';
import 'create_quiz_screen.dart';
import 'manage_users_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final _quizService = QuizService();
  final _authService = AuthService();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboard(),
          const ManageUsersScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateQuizScreen()),
          );
        },
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Yangi Quiz'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppConstants.surfaceColor,
        indicatorColor: AppConstants.primaryColor.withOpacity(0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppConstants.primaryColor),
            label: 'Boshqaruv',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: AppConstants.primaryColor),
            label: 'Foydalanuvchilar',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Panel',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppConstants.warningColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'ADMIN',
                                style: TextStyle(
                                  color: AppConstants.warningColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
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
                  ),
                ],
              ),
            ),
          ),

          // Stats Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: StreamBuilder<List<Quiz>>(
                stream: _quizService.getAllQuizzes(),
                builder: (context, snapshot) {
                  final quizCount = snapshot.data?.length ?? 0;
                  final activeCount = snapshot.data?.where((q) => q.isActive).length ?? 0;

                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Jami Quizlar',
                          '$quizCount',
                          Icons.quiz_outlined,
                          AppConstants.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Faol Quizlar',
                          '$activeCount',
                          Icons.play_circle_outline,
                          AppConstants.successColor,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: StreamBuilder<int>(
                stream: _quizService.getTotalUsersCount(),
                builder: (context, snapshot) {
                  final userCount = snapshot.data ?? 0;
                  return _buildStatCard(
                    'Jami Foydalanuvchilar',
                    '$userCount',
                    Icons.people_outline,
                    AppConstants.accentColor,
                  );
                },
              ),
            ),
          ),

          // Quiz List Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                'Quizlar',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),

          // Quiz List
          StreamBuilder<List<Quiz>>(
            stream: _quizService.getAllQuizzes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.quiz_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Hozircha quizlar yo\'q',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Yangi quiz yarating',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final quizzes = snapshot.data!;
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final quiz = quizzes[index];
                      return _buildQuizCard(quiz);
                    },
                    childCount: quizzes.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: AppConstants.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(Quiz quiz) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: AppConstants.cardShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: quiz.isActive
                ? AppConstants.primaryColor.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.quiz_outlined,
            color: quiz.isActive ? AppConstants.primaryColor : Colors.grey,
          ),
        ),
        title: Text(
          quiz.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(Icons.help_outline, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                '${quiz.questionCount} ta savol',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: quiz.isActive
                      ? AppConstants.successColor.withOpacity(0.1)
                      : AppConstants.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  quiz.isActive ? 'Faol' : 'Nofaol',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: quiz.isActive ? AppConstants.successColor : AppConstants.errorColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'delete') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text('O\'chirish'),
                  content: Text('"${quiz.title}" quizini o\'chirmoqchimisiz?'),
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
                      child: const Text('O\'chirish'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                try {
                  await _quizService.hardDeleteQuiz(quiz.id);
                  if (mounted) {
                    ErrorHandler.showSuccess(context, 'Quiz o\'chirildi');
                  }
                } catch (e) {
                  if (mounted) {
                    ErrorHandler.showError(context, 'Xatolik: $e');
                  }
                }
              }
            } else if (value == 'toggle') {
              try {
                await _quizService.updateQuiz(quiz.id, {'isActive': !quiz.isActive});
              } catch (e) {
                if (mounted) ErrorHandler.showError(context, 'Xatolik: $e');
              }
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    quiz.isActive ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(quiz.isActive ? 'Nofaol qilish' : 'Faol qilish'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18, color: AppConstants.errorColor),
                  SizedBox(width: 8),
                  Text('O\'chirish', style: TextStyle(color: AppConstants.errorColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
