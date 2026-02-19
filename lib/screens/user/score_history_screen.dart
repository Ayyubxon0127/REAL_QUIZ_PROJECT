import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../services/quiz_service.dart';
import '../../models/quiz_score_model.dart';

class ScoreHistoryScreen extends StatelessWidget {
  const ScoreHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Center(child: Text('Foydalanuvchi topilmadi'));
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              'Natijalarim',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Expanded(
            child: StreamBuilder<List<QuizScore>>(
              stream: QuizService().getUserScores(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final scores = snapshot.data ?? [];

                if (scores.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Hali quiz o\'ynamadingiz',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Birinchi quizni boshlang!',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: scores.length,
                  itemBuilder: (context, index) {
                    final score = scores[index];
                    return _buildScoreCard(context, score, index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, QuizScore score, int index) {
    final isPassed = score.isPassed;
    final minutes = score.timeTakenSeconds ~/ 60;
    final seconds = score.timeTakenSeconds % 60;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: AppConstants.cardShadow,
      ),
      child: Row(
        children: [
          // Score circle
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPassed
                  ? AppConstants.successColor.withOpacity(0.1)
                  : AppConstants.errorColor.withOpacity(0.1),
            ),
            child: Center(
              child: Text(
                '${score.percentage.toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isPassed
                      ? AppConstants.successColor
                      : AppConstants.errorColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  score.quizTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.check, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 2),
                    Text(
                      '${score.score}/${score.totalQuestions}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.timer_outlined, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 2),
                    Text(
                      '${minutes}m ${seconds}s',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isPassed
                  ? AppConstants.successColor.withOpacity(0.1)
                  : AppConstants.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isPassed ? 'O\'tdi' : 'O\'tmadi',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isPassed
                    ? AppConstants.successColor
                    : AppConstants.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
