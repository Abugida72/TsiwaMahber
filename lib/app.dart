import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/constants/app_constants.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/features/auth/presentation/auth_gate.dart';

class TsiwaApp extends StatefulWidget {
  const TsiwaApp({super.key});

  @override
  State<TsiwaApp> createState() => _TsiwaAppState();
}

class _TsiwaAppState extends State<TsiwaApp> {
  final _themeProvider = ThemeProvider();
  final _localeProvider = LocaleProvider.instance;

  @override
  void initState() {
    super.initState();
    _themeProvider.addListener(_rebuild);
    _localeProvider.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _themeProvider.removeListener(_rebuild);
    _localeProvider.removeListener(_rebuild);
    _themeProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: _themeProvider.theme,
      home: AuthGate(
        themeProvider: _themeProvider,
        localeProvider: _localeProvider,
      ),
    );
  }
}
