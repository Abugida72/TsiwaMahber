import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsiwa_mahber/core/constants/app_constants.dart';
import 'package:tsiwa_mahber/core/constants/firestore_paths.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/utils/ethiopian_calendar.dart';
import 'package:tsiwa_mahber/features/members/domain/member.dart';
import 'package:tsiwa_mahber/features/leadership/domain/leader.dart';
import 'package:tsiwa_mahber/features/tsiwa/domain/tsiwa_event.dart';

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

    test('event paths are correct', () {
      expect(
        FirestorePaths.events('gelan', 'tsiwa1'),
        'areas/gelan/tsiwaMahbers/tsiwa1/events',
      );
      expect(
        FirestorePaths.event('gelan', 'tsiwa1', 'event1'),
        'areas/gelan/tsiwaMahbers/tsiwa1/events/event1',
      );
    });
  });

  group('EthiopianCalendar', () {
    test('converts known Gregorian date to Ethiopian', () {
      // September 11, 2024 (Gregorian) = Meskerem 1, 2017 (Ethiopian)
      final eth = EthiopianCalendar.fromGregorian(DateTime(2024, 9, 11));
      expect(eth.year, 2017);
      expect(eth.month, 1);
      expect(eth.day, 1);
    });

    test('converts Ethiopian date back to Gregorian', () {
      final greg = EthiopianCalendar.toGregorian(
        const EthiopianDate(year: 2017, month: 1, day: 1),
      );
      expect(greg.year, 2024);
      expect(greg.month, 9);
      expect(greg.day, 11);
    });

    test('round-trip conversion is consistent', () {
      final original = DateTime(2025, 1, 15);
      final eth = EthiopianCalendar.fromGregorian(original);
      final backToGreg = EthiopianCalendar.toGregorian(eth);
      expect(backToGreg.year, original.year);
      expect(backToGreg.month, original.month);
      expect(backToGreg.day, original.day);
    });

    test('EthiopianDate formatted includes month name', () {
      const date = EthiopianDate(year: 2017, month: 1, day: 15);
      expect(date.monthName, 'መስከረም');
      expect(date.shortFormatted, 'መስከረም 15');
      expect(date.formatted, 'መስከረም 15, 2017');
    });

    test('daysInMonth returns 30 for months 1-12', () {
      for (int m = 1; m <= 12; m++) {
        expect(EthiopianCalendar.daysInMonth(2017, m), 30);
      }
    });

    test('daysInMonth returns 5 or 6 for Pagume', () {
      // Ethiopian year 2019 (2019 % 4 == 3) is a leap year
      expect(EthiopianCalendar.daysInMonth(2019, 13), 6);
      // Ethiopian year 2017 (2017 % 4 == 1) is not a leap year
      expect(EthiopianCalendar.daysInMonth(2017, 13), 5);
    });

    test('daysUntilText returns correct Amharic text', () {
      expect(EthiopianCalendar.daysUntilText(0), 'ዛሬ');
      expect(EthiopianCalendar.daysUntilText(1), 'ነገ');
      expect(EthiopianCalendar.daysUntilText(5), '5 ቀናት ቀርተዋል');
      expect(EthiopianCalendar.daysUntilText(-1), '');
    });

    test('today returns a valid date', () {
      final today = EthiopianCalendar.today();
      expect(today.year, greaterThan(2010));
      expect(today.month, inInclusiveRange(1, 13));
      expect(today.day, inInclusiveRange(1, 30));
    });
  });

  group('TsiwaEvent', () {
    test('TsiwaEventType displayName returns Amharic', () {
      expect(TsiwaEventType.monthlyTsiwa.displayName, 'የወርሃዊ ፅዋ');
      expect(TsiwaEventType.zikir.displayName, 'ዝክር');
      expect(TsiwaEventType.feedingDay.displayName, 'ማብላት');
      expect(TsiwaEventType.other.displayName, 'ሌላ');
    });

    test('TsiwaEventType fromString parses correctly', () {
      expect(TsiwaEventType.fromString('monthly_tsiwa'),
          TsiwaEventType.monthlyTsiwa);
      expect(TsiwaEventType.fromString('zikir'), TsiwaEventType.zikir);
      expect(TsiwaEventType.fromString('feeding_day'),
          TsiwaEventType.feedingDay);
      expect(TsiwaEventType.fromString('unknown'), TsiwaEventType.other);
    });

    test('TsiwaEventStatus displayName returns Amharic', () {
      expect(TsiwaEventStatus.planned.displayName, 'የታቀደ');
      expect(TsiwaEventStatus.completed.displayName, 'የተፈጸመ');
      expect(TsiwaEventStatus.cancelled.displayName, 'የተሰረዘ');
    });

    test('TsiwaEventStatus fromString parses correctly', () {
      expect(TsiwaEventStatus.fromString('completed'),
          TsiwaEventStatus.completed);
      expect(TsiwaEventStatus.fromString('cancelled'),
          TsiwaEventStatus.cancelled);
      expect(TsiwaEventStatus.fromString('planned'),
          TsiwaEventStatus.planned);
      expect(TsiwaEventStatus.fromString(null), TsiwaEventStatus.planned);
    });

    test('TsiwaEvent copyWith works correctly', () {
      const original = TsiwaEvent(
        id: '1',
        type: TsiwaEventType.monthlyTsiwa,
        status: TsiwaEventStatus.planned,
        ethiopianYear: 2017,
      );

      final updated = original.copyWith(
        status: TsiwaEventStatus.completed,
        notes: 'Done',
      );

      expect(updated.id, '1');
      expect(updated.type, TsiwaEventType.monthlyTsiwa);
      expect(updated.status, TsiwaEventStatus.completed);
      expect(updated.notes, 'Done');
      expect(updated.ethiopianYear, 2017);
    });
  });

  group('Leader', () {
    test('LeaderRole displayName returns Amharic', () {
      expect(LeaderRole.owner.displayName, 'ባለቤት');
      expect(LeaderRole.amerar.displayName, 'አመራር');
      expect(LeaderRole.memakir.displayName, 'መማክርት');
      expect(LeaderRole.edirAmerar.displayName, 'የእድር አመራር');
      expect(LeaderRole.viewer.displayName, 'ታዛቢ');
    });

    test('LeaderRole fromString parses correctly', () {
      expect(LeaderRole.fromString('owner'), LeaderRole.owner);
      expect(LeaderRole.fromString('amerar'), LeaderRole.amerar);
      expect(LeaderRole.fromString('memakir'), LeaderRole.memakir);
      expect(LeaderRole.fromString('edir_amerar'), LeaderRole.edirAmerar);
      expect(LeaderRole.fromString('unknown'), LeaderRole.viewer);
      expect(LeaderRole.fromString(null), LeaderRole.viewer);
    });

    test('LeaderRole firestoreValue maps correctly', () {
      expect(LeaderRole.owner.firestoreValue, 'owner');
      expect(LeaderRole.amerar.firestoreValue, 'amerar');
      expect(LeaderRole.memakir.firestoreValue, 'memakir');
      expect(LeaderRole.edirAmerar.firestoreValue, 'edir_amerar');
      expect(LeaderRole.viewer.firestoreValue, 'viewer');
    });

    test('Leader copyWith works correctly', () {
      const original = Leader(
        id: '1',
        fullName: 'Test Leader',
        role: LeaderRole.amerar,
        assignedTsiwaIds: ['tsiwa1'],
      );

      final updated = original.copyWith(
        role: LeaderRole.owner,
        isActive: false,
      );

      expect(updated.id, '1');
      expect(updated.fullName, 'Test Leader');
      expect(updated.role, LeaderRole.owner);
      expect(updated.isActive, false);
      expect(updated.assignedTsiwaIds, ['tsiwa1']);
    });

    test('leader paths are correct', () {
      expect(
        FirestorePaths.leaders('gelan'),
        'areas/gelan/leaders',
      );
      expect(
        FirestorePaths.leader('gelan', 'leader1'),
        'areas/gelan/leaders/leader1',
      );
    });
  });
}
