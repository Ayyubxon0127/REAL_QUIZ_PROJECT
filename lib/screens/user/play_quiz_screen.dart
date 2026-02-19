import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../models/quiz_model.dart';
import '../../models/quiz_score_model.dart';
import '../../services/quiz_service.dart';
import 'result_screen.dart';

class PlayQuizScreen extends StatefulWidget {
  final Quiz quiz;

  const PlayQuizScreen({super.key, required this.quiz});

  @override
  State<PlayQuizScreen> createState() => _PlayQuizScreenState();
}

class _PlayQuizScreenState extends State<PlayQuizScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _isAnswerChecked = false;
  final Stopwatch _stopwatch = Stopwatch();

  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _progressController.dispose();
    super.dispose();
  }

  void _checkAnswer(int selectedIndex) {
    if (_isAnswerChecked) return;

    setState(() {
      _selectedAnswerIndex = selectedIndex;
      _isAnswerChecked = true;

      if (selectedIndex ==
          widget.quiz.questions[_currentIndex].correctAnswerIndex) {
        _score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswerIndex = null;
        _isAnswerChecked = false;
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    _stopwatch.stop();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final quizScore = QuizScore(
        id: '',
        userId: user.uid,
        quizId: widget.quiz.id,
        quizTitle: widget.quiz.title,
        score: _score,
        totalQuestions: widget.quiz.questions.length,
        timeTakenSeconds: _stopwatch.elapsed.inSeconds,
      );

      try {
        await QuizService().saveScore(quizScore);
      } catch (_) {
        // Score saving failed but don't block the result screen
      }
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          score: _score,
          totalQuestions: widget.quiz.questions.length,
          quizTitle: widget.quiz.title,
          timeTakenSeconds: _stopwatch.elapsed.inSeconds,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quiz.questions[_currentIndex];
    final progress = (_currentIndex + 1) / widget.quiz.questions.length;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text('Chiqish'),
                content: const Text('Quizdan chiqmoqchimisiz? Natijalar saqlanmaydi.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Yo\'q'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.errorColor,
                    ),
                    child: const Text('Ha, chiqish'),
                  ),
                ],
              ),
            );
          },
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.quiz.questions.length}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConstants.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: AppConstants.warningColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_score',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppConstants.warningColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 400),
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.grey.shade200,
                    color: AppConstants.primaryColor,
                    minHeight: 6,
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // Question text
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                boxShadow: AppConstants.cardShadow,
              ),
              child: Text(
                question.questionText,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Answer options
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  return _buildOptionCard(index, question);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(int index, Question question) {
    final isSelected = _selectedAnswerIndex == index;
    final isCorrect = index == question.correctAnswerIndex;

    Color bgColor = Colors.white;
    Color borderColor = Colors.grey.shade200;
    Color textColor = AppConstants.textPrimary;

    if (_isAnswerChecked) {
      if (isCorrect) {
        bgColor = AppConstants.successColor.withOpacity(0.08);
        borderColor = AppConstants.successColor;
        textColor = AppConstants.successColor;
      } else if (isSelected && !isCorrect) {
        bgColor = AppConstants.errorColor.withOpacity(0.08);
        borderColor = AppConstants.errorColor;
        textColor = AppConstants.errorColor;
      }
    } else if (isSelected) {
      bgColor = AppConstants.primaryColor.withOpacity(0.05);
      borderColor = AppConstants.primaryColor;
    }

    return GestureDetector(
      onTap: () => _checkAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            // Letter circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isAnswerChecked && isCorrect
                    ? AppConstants.successColor
                    : _isAnswerChecked && isSelected && !isCorrect
                        ? AppConstants.errorColor
                        : isSelected
                            ? AppConstants.primaryColor
                            : Colors.grey.shade200,
              ),
              child: Center(
                child: _isAnswerChecked && isCorrect
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : _isAnswerChecked && isSelected && !isCorrect
                        ? const Icon(Icons.close, color: Colors.white, size: 18)
                        : Text(
                            String.fromCharCode(65 + index),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                question.options[index],
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
