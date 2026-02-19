import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String name;
  final String role;
  final DateTime? createdAt;
  final String? photoUrl;
  final int quizzesTaken;
  final int totalScore;

  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.createdAt,
    this.photoUrl,
    this.quizzesTaken = 0,
    this.totalScore = 0,
  });

  bool get isAdmin => role == 'admin';

  double get averageScore =>
      quizzesTaken > 0 ? totalScore / quizzesTaken : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
      'photoUrl': photoUrl ?? '',
      'quizzesTaken': quizzesTaken,
      'totalScore': totalScore,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      role: map['role'] as String? ?? 'user',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      photoUrl: map['photoUrl'] as String?,
      quizzesTaken: map['quizzesTaken'] as int? ?? 0,
      totalScore: map['totalScore'] as int? ?? 0,
    );
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    DateTime? createdAt,
    String? photoUrl,
    int? quizzesTaken,
    int? totalScore,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      photoUrl: photoUrl ?? this.photoUrl,
      quizzesTaken: quizzesTaken ?? this.quizzesTaken,
      totalScore: totalScore ?? this.totalScore,
    );
  }
}
