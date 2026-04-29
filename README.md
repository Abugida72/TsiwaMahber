# ጽዋ / Tsiwa — Ethiopian Orthodox Tsiwa Mahber Management App

**የገላን ፅዋ ማህበሮች** — A management app for Ethiopian Orthodox ጽዋ ማህበሮች (Tsiwa Mahbers), designed for community leaders managing areas, Tsiwa groups, and related activities.

## Features (Version 1)

- **Area Profile**: Default area (የገላን ፅዋ ማህበሮች) with auto-creation
- **Tsiwa Mahber CRUD**: Create, view, edit, and delete Tsiwa Mahbers
- **Monthly Tsiwa Day**: Track the regular monthly meeting day (1–30)
- **Zikir Day (የዝክር ቀን)**: Separate date for memorial/zikir observance
- **Feeding Day (ነድያንን የማብላት ቀን)**: Separate date for community feeding
- **Dark Theme**: Modern dark UI with gold/amber primary color
- **Firestore Backend**: Cloud Firestore with offline persistence
- **Amharic UI**: Full Amharic labels and navigation

## Tech Stack

- **Flutter** (Dart)
- **Firebase Core** + **Cloud Firestore**
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
      domain/tsiwa_mahber.dart
      data/tsiwa_repository.dart
      presentation/
        tsiwa_list_screen.dart
        tsiwa_form_screen.dart
        tsiwa_detail_screen.dart
```

## Firestore Structure

```
areas/{areaId}
  ├── name, shortName, location, description, isActive
  └── tsiwaMahbers/{tsiwaId}
        ├── name, churchName, saintName, location, description
        ├── monthlyTsiwaDay, monthlyTsiwaDayNote
        ├── zikirTitle, zikirMonth, zikirDay, zikirNote
        ├── feedingTitle, feedingMonth, feedingDay, feedingNote
        ├── currentRotationIndex, memberCount, museCount
        └── isActive, isArchived
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
| v2 | Members, Muse assignment |
| v3 | Rotation schedule, Ethiopian calendar |
| v4 | Leadership dashboard (አመራሮች / መማክርት) |
| v5 | Announcements with read confirmation |
| v6 | Edir (እድር) management and payments |
| v7 | Firebase Auth and role-based permissions |
| v8 | Push notifications and Telegram integration |

## License

Private — for የገላን ፅዋ ማህበሮች community use.
