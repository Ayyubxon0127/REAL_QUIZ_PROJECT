import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;

  const Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionText': questionText,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as String? ?? '',
      questionText: map['questionText'] as String? ?? '',
      options: List<String>.from(map['options'] as List? ?? []),
      correctAnswerIndex: map['correctAnswerIndex'] as int? ?? 0,
    );
  }

  Question copyWith({
    String? id,
    String? questionText,
    List<String>? options,
    int? correctAnswerIndex,
  }) {
    return Question(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
    );
  }
}

class Quiz {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final List<Question> questions;
  final DateTime? createdAt;
  final String? category;
  final int timeLimitSeconds;
  final bool isActive;

  const Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.questions,
    this.createdAt,
    this.category,
    this.timeLimitSeconds = 0,
    this.isActive = true,
  });

  int get questionCount => questions.length;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'questions': questions.map((q) => q.toMap()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
      'category': category ?? '',
      'timeLimitSeconds': timeLimitSeconds,
      'isActive': isActive,
    };
  }

  factory Quiz.fromMap(Map<String, dynamic> map, String docId) {
    return Quiz(
      id: docId,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      createdBy: map['createdBy'] as String? ?? '',
      questions: (map['questions'] as List<dynamic>?)
              ?.map((q) => Question.fromMap(q as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      category: map['category'] as String?,
      timeLimitSeconds: map['timeLimitSeconds'] as int? ?? 0,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Quiz copyWith({
    String? id,
    String? title,
    String? description,
    String? createdBy,
    List<Question>? questions,
    DateTime? createdAt,
    String? category,
    int? timeLimitSeconds,
    bool? isActive,
  }) {
    return Quiz(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      questions: questions ?? this.questions,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      isActive: isActive ?? this.isActive,
    );
  }
}
