import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsiwa_mahber/core/constants/app_constants.dart';
import 'package:tsiwa_mahber/core/constants/firestore_paths.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/features/members/domain/member.dart';

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

  group('Member', () {
    test('MemberRole displayName returns Amharic', () {
      expect(MemberRole.muse.displayName, 'ሙሴ');
      expect(MemberRole.assistantMuse.displayName, 'ረዳት ሙሴ');
      expect(MemberRole.member.displayName, 'አባል');
      expect(MemberRole.observer.displayName, 'ታዛቢ');
    });

    test('MemberRole fromString parses correctly', () {
      expect(MemberRole.fromString('muse'), MemberRole.muse);
      expect(MemberRole.fromString('assistant_muse'), MemberRole.assistantMuse);
      expect(MemberRole.fromString('observer'), MemberRole.observer);
      expect(MemberRole.fromString('member'), MemberRole.member);
      expect(MemberRole.fromString(null), MemberRole.member);
      expect(MemberRole.fromString('unknown'), MemberRole.member);
    });

    test('Member normalizedPhone extracts last 9 digits', () {
      const m1 = Member(phone: '+251912345678');
      expect(m1.normalizedPhone, '912345678');

      const m2 = Member(phone: '0912345678');
      expect(m2.normalizedPhone, '912345678');

      const m3 = Member(phone: '912345678');
      expect(m3.normalizedPhone, '912345678');

      const m4 = Member(phone: '123');
      expect(m4.normalizedPhone, '123');
    });

    test('Member copyWith works correctly', () {
      const original = Member(
        id: '1',
        fullName: 'Test Name',
        role: MemberRole.member,
        orderIndex: 5,
      );

      final updated = original.copyWith(
        role: MemberRole.muse,
        orderIndex: 1,
      );

      expect(updated.id, '1');
      expect(updated.fullName, 'Test Name');
      expect(updated.role, MemberRole.muse);
      expect(updated.orderIndex, 1);
    });

    test('MemberRole firestoreValue maps correctly', () {
      expect(MemberRole.muse.firestoreValue, 'muse');
      expect(MemberRole.assistantMuse.firestoreValue, 'assistant_muse');
      expect(MemberRole.member.firestoreValue, 'member');
      expect(MemberRole.observer.firestoreValue, 'observer');
    });
  });

  group('FirestorePaths', () {
    test('member paths are correct', () {
      expect(
        FirestorePaths.members('gelan', 'tsiwa1'),
        'areas/gelan/tsiwaMahbers/tsiwa1/members',
      );
      expect(
        FirestorePaths.member('gelan', 'tsiwa1', 'member1'),
        'areas/gelan/tsiwaMahbers/tsiwa1/members/member1',
      );
    });
  });
}
