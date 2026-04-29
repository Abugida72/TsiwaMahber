import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/auth/data/auth_repository.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/features/auth/presentation/login_screen.dart';
import 'package:tsiwa_mahber/features/area/presentation/area_home_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authRepository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authRepository.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: LoadingState(message: 'በመጫን ላይ...'),
          );
        }

        final firebaseUser = snapshot.data;

        if (firebaseUser == null) {
          return const LoginScreen();
        }

        return StreamBuilder<AppUser?>(
          stream: _authRepository.watchAppUser(firebaseUser.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: LoadingState(message: 'ተጠቃሚ በመጫን ላይ...'),
              );
            }

            final appUser = userSnapshot.data;

            if (appUser != null && !appUser.isActive) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.block, size: 64,
                            color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        const Text(
                          'አካውንትዎ ታግዷል',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'አስተዳዳሪን ያነጋግሩ',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => _authRepository.signOut(),
                          child: const Text('ውጣ'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return AreaHomeScreen(
              currentUser: appUser,
            );
          },
        );
      },
    );
  }
}
