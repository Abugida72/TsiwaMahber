# ጽዋ / Tsiwa — Ethiopian Orthodox Tsiwa Mahber Management App

**የገላን ፅዋ ማህበሮች** — A management app for Ethiopian Orthodox ጽዋ ማህበሮች (Tsiwa Mahbers), designed for community leaders managing areas, Tsiwa groups, and related activities.

## Features

### Version 1 — Core
- **Area Profile**: Default area (የገላን ፅዋ ማህበሮች) with auto-creation
- **Tsiwa Mahber CRUD**: Create, view, edit, and delete Tsiwa Mahbers
- **Monthly Tsiwa Day**: Track the regular monthly meeting day (1–30)
- **Zikir Day (የዝክር ቀን)**: Separate date for memorial/zikir observance
- **Feeding Day (ነድያንን የማብላት ቀን)**: Separate date for community feeding
- **Dark Theme**: Modern dark UI with gold/amber primary color
- **Firestore Backend**: Cloud Firestore with offline persistence
- **Amharic UI**: Full Amharic labels and navigation

### Version 2 — Members & Muse
- **Member Management**: Add, edit, soft-delete members per Tsiwa
- **Roles**: ሙሴ, ረዳት ሙሴ, አባል, ታዛቢ with badges
- **Duplicate Prevention**: Phone and name collision checks
- **Rotation Order**: Auto-assigned ተራ ቁጥር

### Version 3 — Rotation & Ethiopian Calendar
- **Ethiopian Calendar**: Gregorian↔Ethiopian date conversion
- **Countdown Chips**: Days until next ፅዋ, ዝክር, ማብላት
- **Rotation Management**: Current/next member, manual override
- **Event History**: Log and track monthly events

### Version 4 — Leadership Dashboard
- **Leaders (አመራሮች)**: CRUD with role assignment
- **Tsiwa Assignment**: Assign leaders to specific Tsiwas
- **Dashboard Stats**: Tsiwa, Leader, and Edir counts on home screen

### Version 5 — Edir (እድር)
- **Edir CRUD**: Create, edit, delete Edir groups
- **Edir Members**: Add/edit/delete members with status tracking (ንቁ/ቦዝኗል/የታገደ)
- **Payment Recording**: Monthly, penalty, and other payment types
- **Payment History**: Full transaction log with Ethiopian month tracking
- **Treasury Tracking**: Auto-updated treasury balance
- **Balance Tracking**: Per-member paid/owed amounts

### Version 6 — Firebase Auth
- **Email/Password Auth**: Sign in, register, password reset
- **User Roles**: አስተዳዳሪ (admin), አመራር (leader), አባል (member), ታዛቢ (viewer)
- **Auth Gate**: Login required — shows login screen when signed out
- **Profile Screen**: View/edit name and phone, logout
- **User Management**: Admin-only screen to assign roles
- **Role Permissions**: canEdit (admin/leader), canDelete (admin), canManageUsers (admin)
- **Default Role**: New users start as ታዛቢ (viewer)

### Version 7 — Announcements
- **Announcement CRUD**: Create, edit, delete announcements (admin/leader only)
- **Priority Levels**: መደበኛ (normal), አስፈላጊ (important), አስተካክል (urgent) with color badges
- **Read Confirmation**: Users mark announcements as read (አንብቤአለሁ)
- **Read Receipts**: See who read each announcement and when
- **Unread Badge**: Home screen shows unread count on announcements card
- **Detail View**: Full announcement with author, timestamp, and reader list

### Version 8 — Notifications & Telegram
- **In-app Notifications**: Notification bell with unread badge in AppBar
- **Notification List**: View all notifications with swipe-to-delete, mark all as read
- **Auto-notify**: Creating an announcement sends in-app notifications to all users
- **Telegram Bot**: Connect a Telegram bot to auto-post announcements to a group
- **Telegram Settings**: Admin screen to configure bot token, chat ID, test connection
- **FCM Ready**: Firebase Cloud Messaging service for push notifications
- **Relative Time**: Shows "አሁን", "5 ደቂቃ", "2 ሰአት" etc. for notification times

### Version 9 — CSV Import/Export
- **CSV Export**: Export Tsiwa members, Leaders, or Edir members to CSV files
- **CSV Import**: Import data from CSV files with preview and validation
- **Amharic Headers**: CSV columns use Amharic labels (ሙሉ ስም, ስልክ, ሚና, etc.)
- **BOM Support**: UTF-8 BOM prefix for proper Amharic display in Excel
- **Data Preview**: Preview parsed data in a table before importing
- **Batch Write**: Efficient Firestore batch writes for imported records
- **Role Permissions**: CSV features available to admin and leader roles only
- **Share Integration**: Share exported CSV via system share sheet

## Tech Stack

- **Flutter** (Dart)
- **Firebase Core** + **Cloud Firestore** + **Firebase Auth** + **Firebase Messaging**
- Material 3 design
- Clean architecture (domain / data / presentation)

## Project Structure

```
lib/
  main.dart
  app.dart
  firebase_options.dart
  core/
    constants/
      app_constants.dart
      firestore_paths.dart
    theme/
      app_theme.dart
    widgets/
      app_card.dart
      confirm_dialog.dart
      empty_state.dart
      loading_state.dart
  features/
    area/
      domain/area.dart
      data/area_repository.dart
      presentation/area_home_screen.dart
    tsiwa/
      domain/{tsiwa_mahber,tsiwa_event}.dart
      data/{tsiwa_repository,tsiwa_event_repository}.dart
      presentation/{tsiwa_list,tsiwa_form,tsiwa_detail,rotation}_screen.dart
    members/
      domain/member.dart
      data/member_repository.dart
      presentation/{member_list,member_form}_screen.dart
    leadership/
      domain/leader.dart
      data/leader_repository.dart
      presentation/{leader_list,leader_form}_screen.dart
    edir/
      domain/{edir,edir_member,payment}.dart
      data/edir_repository.dart
      presentation/{edir_list,edir_form,edir_detail}_screen.dart
      presentation/{edir_member_list,edir_member_form}_screen.dart
      presentation/{record_payment,edir_payment_list}_screen.dart
    auth/
      domain/app_user.dart
      data/auth_repository.dart
      presentation/{auth_gate,login,register,profile,user_management}_screen.dart
    announcements/
      domain/{announcement,read_receipt}.dart
      data/announcement_repository.dart
      presentation/{announcement_list,announcement_detail,announcement_form}_screen.dart
    notifications/
      domain/app_notification.dart
      data/{notification_repository,fcm_service,telegram_service}.dart
      presentation/{notification_list,telegram_settings}_screen.dart
    csv_io/
      data/csv_service.dart
      presentation/{csv_export,csv_import}_screen.dart
```

## Firestore Structure

```
areas/{areaId}
  ├── name, shortName, location, description, isActive
  ├── tsiwaMahbers/{tsiwaId}
  │     ├── name, churchName, saintName, location, description
  │     ├── monthlyTsiwaDay, zikirMonth/Day, feedingMonth/Day
  │     ├── members/{memberId} — fullName, role, orderIndex, phone
  │     └── events/{eventId} — type, status, responsibleMemberId
  ├── leaders/{leaderId}
  │     └── fullName, role, assignedTsiwaIds, assignedEdirIds
  ├── edirs/{edirId}
  │     ├── name, monthlyContribution, penaltyAmount, treasury, paymentDay
  │     ├── members/{memberId} — fullName, status, totalPaid, balance
  │     └── payments/{paymentId} — memberId, type, amount, forMonth/Year
  └── announcements/{announcementId}
        ├── title, body, priority, authorId, authorName, readCount, isActive
        └── readReceipts/{userId} — userName, readAt
users/{uid} — email, displayName, phone, role, areaId, isActive
```

## Getting Started

### Prerequisites
- Flutter SDK (stable channel)
- Java 17
- Firebase project configured

### Setup
```bash
flutter pub get
flutterfire configure  # Generate real firebase_options.dart
flutter run
```

### Build
```bash
flutter build apk --debug
flutter build apk --release
flutter build apk --release --split-per-abi
flutter build web
```

### Test & Analyze
```bash
flutter analyze
flutter test
```

## CI/CD

GitHub Actions workflow (`.github/workflows/flutter.yml`) runs on every push/PR:
- Flutter analyze
- Flutter test
- Debug APK build
- APK artifact upload

## Future Versions

| Version | Features |
|---------|----------|
| ~~v9~~ | ~~CSV import/export~~ (done) |
| v10 | Advanced reports and analytics |

## License

Private — for የገላን ፅዋ ማህበሮች community use.
