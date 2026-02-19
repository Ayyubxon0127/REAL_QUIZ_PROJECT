import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/app_user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current Firebase user
  User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  /// Login with email and password
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = credential.user;
    if (user == null) throw Exception('Login muvaffaqiyatsiz');

    return await _getOrCreateUserDoc(user);
  }

  /// Register a new user
  Future<AppUser> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = credential.user;
    if (user == null) throw Exception('Ro\'yxatdan o\'tish muvaffaqiyatsiz');

    // Update display name
    await user.updateDisplayName(name.trim());

    // Create user document with role "user"
    final appUser = AppUser(
      uid: user.uid,
      email: email.trim(),
      name: name.trim(),
      role: AppConstants.roleUser,
    );

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(appUser.toMap());

    return appUser;
  }

  /// Get current user's AppUser data
  Future<AppUser?> getCurrentAppUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .get();

    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!, user.uid);
  }

  /// Stream of current user data (for reactive updates)
  Stream<AppUser?> currentAppUserStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromMap(doc.data()!, user.uid);
    });
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('Foydalanuvchi topilmadi');
    }

    // Re-authenticate
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // Update password
    await user.updatePassword(newPassword);
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // Private: Get or create user document
  Future<AppUser> _getOrCreateUserDoc(User user) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .get();

    if (doc.exists) {
      return AppUser.fromMap(doc.data()!, user.uid);
    }

    // Create a new user document if missing (defensive)
    final appUser = AppUser(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? '',
      role: AppConstants.roleUser,
    );

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(appUser.toMap());

    return appUser;
  }
}
