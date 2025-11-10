import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/screens/admin/admin_main.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/seller/seller_main.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // App is still waiting for auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If user is logged in
        if (snapshot.hasData) {
          final user = snapshot.data!;
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, userDocSnapshot) {
              if (userDocSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (userDocSnapshot.hasData && userDocSnapshot.data!.exists) {
                final userData = userDocSnapshot.data!.data() as Map<String, dynamic>;
                final role = userData['role'];

                if (role == 'admin') {
                  return const AdminMain();
                } else if (role == 'seller') {
                  return const SellerMain();
                }
              }

              // If role is not found or document doesn't exist, default to login screen
              return const LoginScreen();
            },
          );
        }

        // If user is not logged in
        return const LoginScreen();
      },
    );
  }
}
