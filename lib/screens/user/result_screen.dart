import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final String quizTitle;
  final int timeTakenSeconds;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.quizTitle,
    required this.timeTakenSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalQuestions > 0 ? (score / totalQuestions) * 100 : 0.0;
    final isPassed = percentage >= 50;
    final isExcellent = percentage >= 80;
    final minutes = timeTakenSeconds ~/ 60;
    final seconds = timeTakenSeconds % 60;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Result icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: (isExcellent
                          ? AppConstants.successColor
                          : isPassed
                              ? AppConstants.warningColor
                              : AppConstants.errorColor)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isExcellent
                      ? Icons.emoji_events
                      : isPassed
                          ? Icons.thumb_up_alt_rounded
                          : Icons.refresh,
                  size: 56,
                  color: isExcellent
                      ? AppConstants.successColor
                      : isPassed
                          ? AppConstants.warningColor
                          : AppConstants.errorColor,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                isExcellent
                    ? 'Ajoyib natija!'
                    : isPassed
                        ? 'Yaxshi harakat!'
                        : 'Qaytadan urinib ko\'ring',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                quizTitle,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Score circle
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isExcellent
                        ? [
                            AppConstants.successColor,
                            AppConstants.successColor.withOpacity(0.7),
                          ]
                        : isPassed
                            ? [
                                AppConstants.warningColor,
                                AppConstants.warningColor.withOpacity(0.7),
                              ]
                            : [
                                AppConstants.errorColor,
                                AppConstants.errorColor.withOpacity(0.7),
                              ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${percentage.toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Stats
              Row(
                children: [
                  _buildStatItem(
                    context,
                    'To\'g\'ri',
                    '$score',
                    Icons.check_circle,
                    AppConstants.successColor,
                  ),
                  const SizedBox(width: 12),
                  _buildStatItem(
                    context,
                    'Noto\'g\'ri',
                    '${totalQuestions - score}',
                    Icons.cancel,
                    AppConstants.errorColor,
                  ),
                  const SizedBox(width: 12),
                  _buildStatItem(
                    context,
                    'Vaqt',
                    '${minutes}m ${seconds}s',
                    Icons.timer,
                    AppConstants.primaryColor,
                  ),
                ],
              ),

              const Spacer(),

              // Buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Bosh sahifaga qaytish'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    // Pop back to before quiz detail
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Boshqa quizni tanlash'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          boxShadow: AppConstants.cardShadow,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
