import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../services/auth_service.dart';
import '../../services/quiz_service.dart';
import '../../models/quiz_model.dart';
import '../../models/app_user_model.dart';
import 'play_quiz_screen.dart';
import 'quiz_detail_screen.dart';
import 'profile_screen.dart';
import 'score_history_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
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
          _buildQuizList(),
          const ScoreHistoryScreen(),
          const UserProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppConstants.surfaceColor,
        indicatorColor: AppConstants.primaryColor.withOpacity(0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz, color: AppConstants.primaryColor),
            label: 'Quizlar',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events, color: AppConstants.primaryColor),
            label: 'Natijalar',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppConstants.primaryColor),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildQuizList() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: StreamBuilder<AppUser?>(
                stream: _authService.currentAppUserStream(),
                builder: (context, snapshot) {
                  final name = snapshot.data?.name ?? 'Foydalanuvchi';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Salom, $name',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Bilimingizni sinab ko\'ring',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Stats row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: StreamBuilder<AppUser?>(
                stream: _authService.currentAppUserStream(),
                builder: (context, snapshot) {
                  final user = snapshot.data;
                  return Row(
                    children: [
                      Expanded(
                        child: _buildMiniStat(
                          'O\'ynalgan',
                          '${user?.quizzesTaken ?? 0}',
                          Icons.play_circle_outline,
                          AppConstants.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMiniStat(
                          'Jami ball',
                          '${user?.totalScore ?? 0}',
                          Icons.star_outline,
                          AppConstants.warningColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMiniStat(
                          'O\'rtacha',
                          '${user?.averageScore.toStringAsFixed(1) ?? '0.0'}',
                          Icons.trending_up,
                          AppConstants.successColor,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Section title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Text(
                'Mavjud quizlar',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),

          // Quiz cards
          StreamBuilder<List<Quiz>>(
            stream: _quizService.getQuizzes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text('Xatolik: ${snapshot.error}'),
                  ),
                );
              }

              final quizzes = snapshot.data ?? [];

              if (quizzes.isEmpty) {
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
                        const SizedBox(height: 4),
                        Text(
                          'Tez orada yangi quizlar qo\'shiladi',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final quiz = quizzes[index];
                      return _buildQuizCard(quiz, index);
                    },
                    childCount: quizzes.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: AppConstants.cardShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(Quiz quiz, int index) {
    final colors = [
      AppConstants.primaryColor,
      AppConstants.accentColor,
      AppConstants.warningColor,
      AppConstants.successColor,
    ];
    final color = colors[index % colors.length];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizDetailScreen(quiz: quiz),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          boxShadow: AppConstants.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Quiz icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Quiz info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (quiz.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        quiz.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.help_outline,
                          '${quiz.questionCount} savol',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
