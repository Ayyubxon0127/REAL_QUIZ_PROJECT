import 'package:cloud_firestore/cloud_firestore.dart';

class QuizScore {
  final String id;
  final String userId;
  final String quizId;
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final DateTime? completedAt;
  final int timeTakenSeconds;

  const QuizScore({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    this.completedAt,
    this.timeTakenSeconds = 0,
  });

  double get percentage =>
      totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;

  bool get isPassed => percentage >= 50;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'quizId': quizId,
      'quizTitle': quizTitle,
      'score': score,
      'totalQuestions': totalQuestions,
      'completedAt': FieldValue.serverTimestamp(),
      'timeTakenSeconds': timeTakenSeconds,
    };
  }

  factory QuizScore.fromMap(Map<String, dynamic> map, String docId) {
    return QuizScore(
      id: docId,
      userId: map['userId'] as String? ?? '',
      quizId: map['quizId'] as String? ?? '',
      quizTitle: map['quizTitle'] as String? ?? '',
      score: map['score'] as int? ?? 0,
      totalQuestions: map['totalQuestions'] as int? ?? 0,
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      timeTakenSeconds: map['timeTakenSeconds'] as int? ?? 0,
    );
  }
}
