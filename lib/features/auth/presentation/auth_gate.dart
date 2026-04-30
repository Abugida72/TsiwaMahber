import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/app_popup_menu.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/auth/data/auth_repository.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/features/auth/presentation/login_screen.dart';
import 'package:tsiwa_mahber/features/area/presentation/area_selection_screen.dart';
import 'package:tsiwa_mahber/features/area/presentation/area_home_screen.dart';

class AuthGate extends StatefulWidget {
  final ThemeProvider themeProvider;
  final LocaleProvider localeProvider;

  const AuthGate({
    super.key,
    required this.themeProvider,
    required this.localeProvider,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authRepository = AuthRepository();

  /// Non-null when a member has logged in via phone+code.
  AppUser? _memberUser;

  /// Real-time subscription to the member's Firestore document.
  StreamSubscription<AppUser?>? _memberWatchSub;

  void _onMemberLogin(AppUser user) {
    _memberWatchSub?.cancel();
    _memberWatchSub = _authRepository.watchAppUser(user.uid).listen((updated) {
      if (!mounted) return;
      if (updated == null || updated.kickedOut || !updated.isActive) {
        _logoutMember();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.accountKicked)),
          );
        }
        return;
      }
      setState(() => _memberUser = updated);
    });
    setState(() => _memberUser = user);
  }

  void _logoutMember() {
    _memberWatchSub?.cancel();
    _memberWatchSub = null;
    setState(() => _memberUser = null);
  }

  @override
  void dispose() {
    _memberWatchSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ── Developer path: Firebase Auth ──
    return StreamBuilder<User?>(
      stream: _authRepository.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: LoadingState(message: S.loading),
          );
        }

        final firebaseUser = snapshot.data;

        // Developer is signed in via Google/Firebase Auth
        if (firebaseUser != null) {
          return StreamBuilder<AppUser?>(
            stream: _authRepository.watchAppUser(firebaseUser.uid),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return Scaffold(
                  body: LoadingState(message: S.loadingUser),
                );
              }

              final appUser = userSnapshot.data;

              if (appUser != null && !appUser.isActive) {
                return _buildBlockedScreen();
              }

              // Developers see area selection
              return AreaSelectionScreen(
                currentUser: appUser,
                themeProvider: widget.themeProvider,
                localeProvider: widget.localeProvider,
              );
            },
          );
        }

        // ── Member path: phone+code session ──
        if (_memberUser != null) {
          // Members go directly to their assigned area
          return AreaHomeScreen(
            currentUser: _memberUser,
            areaId: _memberUser!.areaId,
            areaName: _memberUser!.areaId,
            themeProvider: widget.themeProvider,
            localeProvider: widget.localeProvider,
            onLogout: _logoutMember,
          );
        }

        // Not logged in — show phone+code login
        return LoginScreen(
          themeProvider: widget.themeProvider,
          localeProvider: widget.localeProvider,
          onMemberLogin: _onMemberLogin,
        );
      },
    );
  }

  Widget _buildBlockedScreen() {
    return Scaffold(
      appBar: AppBar(
        actions: [
          AppPopupMenu(
            themeProvider: widget.themeProvider,
            localeProvider: widget.localeProvider,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 64,
                  color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                S.accountBlocked,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                S.contactAdmin,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _authRepository.signOut(),
                child: Text(S.exitAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
