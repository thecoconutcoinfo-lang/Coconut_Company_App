import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/admin/admin_main.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/seller/seller_main.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final userRole = userSnapshot.data!['role'];
                final userProvider = Provider.of<UserProvider>(context, listen: false);

                // Schedule the state update for after the build phase to avoid errors
                WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (userProvider.userRole == UserRole.none) { // Set role only if not already set
                        if (userRole == 'admin') {
                            userProvider.setUserRole(UserRole.admin);
                        } else if (userRole == 'seller') {
                            userProvider.setUserRole(UserRole.seller);
                        }
                    }
                });

                if (userRole == 'admin') {
                  return const AdminMain();
                } else if (userRole == 'seller') {
                  return const SellerMain();
                }
              }

              // Fallback to login screen if role not found or something went wrong
              return const LoginScreen();
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}
