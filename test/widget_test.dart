import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsiwa_mahber/core/constants/app_constants.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';

void main() {
  group('AppConstants', () {
    test('default area values are correct', () {
      expect(AppConstants.defaultAreaId, 'gelan');
      expect(AppConstants.defaultAreaName, 'የገላን ፅዋ ማህበሮች');
      expect(AppConstants.defaultAreaShortName, 'ገላን');
    });

    test('Ethiopian month names has 13 entries', () {
      expect(AppConstants.ethiopianMonths.length, 13);
    });

    test('ethiopianMonthName returns correct name', () {
      expect(AppConstants.ethiopianMonthName(1), 'መስከረም');
      expect(AppConstants.ethiopianMonthName(5), 'ጥር');
      expect(AppConstants.ethiopianMonthName(13), 'ጳጉሜ');
    });

    test('ethiopianMonthName returns empty for invalid month', () {
      expect(AppConstants.ethiopianMonthName(0), '');
      expect(AppConstants.ethiopianMonthName(14), '');
    });
  });

  group('AppTheme', () {
    test('darkTheme is dark brightness', () {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
    });

    test('darkTheme uses Material 3', () {
      final theme = AppTheme.darkTheme;
      expect(theme.useMaterial3, true);
    });

    test('darkTheme has correct primary color', () {
      final theme = AppTheme.darkTheme;
      expect(theme.colorScheme.primary, AppTheme.primary);
    });
  });

  group('Widget tests', () {
    testWidgets('MaterialApp can be created with theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          title: AppConstants.appName,
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: Center(
              child: Text('Tsiwa Test'),
            ),
          ),
        ),
      );

      expect(find.text('Tsiwa Test'), findsOneWidget);
    });
  });
}
