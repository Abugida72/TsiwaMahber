import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/features/developer/data/developer_service.dart';

class AppPopupMenu extends StatelessWidget {
  final ThemeProvider themeProvider;
  final LocaleProvider localeProvider;

  const AppPopupMenu({
    super.key,
    required this.themeProvider,
    required this.localeProvider,
  });

  @override
  Widget build(BuildContext context) {
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
              themeProvider.isDarkMode ? 'ብሩህ ገጽታ' : 'ጨለማ ገጽታ',
            ),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'dev_login',
          child: ListTile(
            leading: Icon(Icons.code, size: 20),
            title: Text('ገንቢ ግባ'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'exit',
          child: ListTile(
            leading: Icon(Icons.exit_to_app, size: 20,
                color: Colors.red),
            title: Text('ውጣ',
                style: TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
      ],
    );
  }

  void _handleSelection(BuildContext context, String value) {
    switch (value) {
      case 'language':
        localeProvider.toggleLanguage();
        final label = localeProvider.isAmharic ? 'አማርኛ' : 'English';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Language: $label')),
        );
        break;
      case 'theme':
        themeProvider.toggleTheme();
        break;
      case 'dev_login':
        _handleDevLogin(context);
        break;
      case 'exit':
        exit(0);
    }
  }

  Future<void> _handleDevLogin(BuildContext context) async {
    final devService = DeveloperService();

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

    if (context.mounted) {
      Navigator.pop(context); // dismiss dialog

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }
}
