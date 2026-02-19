import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/app_user_model.dart';
import 'splash_screen.dart';
import 'auth/login_screen.dart';
import 'admin/admin_home_screen.dart';
import 'user/user_home_screen.dart';

/// Listens to auth state and routes to the correct screen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // Still loading auth state
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // Not logged in
        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return const LoginScreen();
        }

        // Logged in - determine role
        final user = authSnapshot.data!;
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection(AppConstants.usersCollection)
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              // User document doesn't exist yet - show user screen by default
              return const UserHomeScreen();
            }

            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            final appUser = AppUser.fromMap(userData, user.uid);

            if (appUser.isAdmin) {
              return const AdminHomeScreen();
            }

            return const UserHomeScreen();
          },
        );
      },
    );
  }
}
