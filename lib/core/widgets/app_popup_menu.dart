import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/features/developer/data/developer_service.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

class AppPopupMenu extends StatelessWidget {
  final ThemeProvider themeProvider;
  final LocaleProvider localeProvider;
  final VoidCallback? onMemberLogout;

  const AppPopupMenu({
    super.key,
    required this.themeProvider,
    required this.localeProvider,
    this.onMemberLogout,
  });

  @override
  Widget build(BuildContext context) {
    final isFirebaseSignedIn = FirebaseAuth.instance.currentUser != null;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) => _handleSelection(context, value),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'language',
          child: ListTile(
            leading: const Icon(Icons.language, size: 20),
            title: Text(
              localeProvider.isAmharic ? 'English' : 'አማርኛ',
            ),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        PopupMenuItem<String>(
          value: 'theme',
          child: ListTile(
            leading: Icon(
              themeProvider.isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
              size: 20,
            ),
            title: Text(
              themeProvider.isDarkMode ? S.lightTheme : S.darkTheme,
            ),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'dev_login',
          child: ListTile(
            leading: const Icon(Icons.code, size: 20),
            title: Text(S.devSignIn),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        if (isFirebaseSignedIn || onMemberLogout != null)
          PopupMenuItem<String>(
            value: 'sign_out',
            child: ListTile(
              leading: const Icon(Icons.logout, size: 20,
                  color: Colors.orange),
              title: Text(S.signOut,
                  style: const TextStyle(color: Colors.orange)),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'exit',
          child: ListTile(
            leading: const Icon(Icons.exit_to_app, size: 20,
                color: Colors.red),
            title: Text(S.exitApp,
                style: const TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSelection(BuildContext context, String value) async {
    switch (value) {
      case 'language':
        localeProvider.toggleLanguage();
        final label = localeProvider.isAmharic ? 'አማርኛ' : 'English';
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Language: $label')),
          );
        }
        break;
      case 'theme':
        themeProvider.toggleTheme();
        break;
      case 'dev_login':
        _handleDevLogin(context);
        break;
      case 'sign_out':
        if (onMemberLogout != null) {
          onMemberLogout!();
        } else {
          await GoogleSignIn().signOut();
          await FirebaseAuth.instance.signOut();
        }
        break;
      case 'exit':
        exit(0);
    }
  }

  Future<void> _handleDevLogin(BuildContext context) async {
    final devService = DeveloperService();
    final rootNavigator = Navigator.of(context, rootNavigator: true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Google Sign-In...'),
          ],
        ),
      ),
    );

    final error = await devService.signInWithGoogle();

    try {
      rootNavigator.pop();
    } catch (_) {
      // Dialog already dismissed by auth-state navigation
    }

    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }
}
