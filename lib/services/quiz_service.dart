import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/quiz_model.dart';
import '../models/quiz_score_model.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of all active quizzes (ordered by creation date)
  Stream<List<Quiz>> getQuizzes() {
    return _firestore
        .collection(AppConstants.quizzesCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Quiz.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Stream of all quizzes (for admin - includes inactive)
  Stream<List<Quiz>> getAllQuizzes() {
    return _firestore
        .collection(AppConstants.quizzesCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Quiz.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Stream of quizzes created by specific admin
  Stream<List<Quiz>> getQuizzesByCreator(String userId) {
    return _firestore
        .collection(AppConstants.quizzesCollection)
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Quiz.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Create a new quiz
  Future<String> createQuiz(Quiz quiz) async {
    final docRef = await _firestore
        .collection(AppConstants.quizzesCollection)
        .add(quiz.toMap());
    return docRef.id;
  }

  /// Update an existing quiz
  Future<void> updateQuiz(String quizId, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.quizzesCollection)
        .doc(quizId)
        .update(data);
  }

  /// Delete a quiz (soft delete - set isActive to false)
  Future<void> deleteQuiz(String quizId) async {
    await _firestore
        .collection(AppConstants.quizzesCollection)
        .doc(quizId)
        .update({'isActive': false});
  }

  /// Hard delete a quiz
  Future<void> hardDeleteQuiz(String quizId) async {
    await _firestore
        .collection(AppConstants.quizzesCollection)
        .doc(quizId)
        .delete();
  }

  /// Save quiz score
  Future<void> saveScore(QuizScore score) async {
    // Save to scores collection
    await _firestore
        .collection(AppConstants.scoresCollection)
        .add(score.toMap());

    // Update user statistics atomically
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(score.userId)
        .update({
      'quizzesTaken': FieldValue.increment(1),
      'totalScore': FieldValue.increment(score.score),
    });
  }

  /// Get scores for a specific user
  Stream<List<QuizScore>> getUserScores(String userId) {
    return _firestore
        .collection(AppConstants.scoresCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return QuizScore.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Get all scores for a specific quiz (leaderboard)
  Stream<List<QuizScore>> getQuizScores(String quizId) {
    return _firestore
        .collection(AppConstants.scoresCollection)
        .where('quizId', isEqualTo: quizId)
        .orderBy('score', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return QuizScore.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Get user's best score for a specific quiz
  Future<QuizScore?> getUserBestScore(String userId, String quizId) async {
    final snapshot = await _firestore
        .collection(AppConstants.scoresCollection)
        .where('userId', isEqualTo: userId)
        .where('quizId', isEqualTo: quizId)
        .orderBy('score', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return QuizScore.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
  }

  /// Get total number of users
  Stream<int> getTotalUsersCount() {
    return _firestore
        .collection(AppConstants.usersCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
