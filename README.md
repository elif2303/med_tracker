# Med Tracker

A simple medication reminder app for the whole family, built with Flutter (Android first). Add your medicines, set the times and days, and get a reliable notification or a loud alarm when it is time to take them. Everything stays on your device.

## Features

- **Medicines and reminders:** several reminder times per medicine, with selectable days of the week
- **Notifications and alarm mode:** a normal notification, or a full-screen alarm that can wake the phone, which suits people who tend to miss a notification
- **Action buttons:** mark a dose as taken directly from the notification
- **Survives reboot:** reminders are rescheduled after the phone restarts
- **Profiles:** track medicines for several people (for example parents or children) on one phone, each with their own colour
- **Calendar strip:** see the week at a glance and what was taken or missed
- **Simple, readable interface:** large touch targets and clear text; follows the system text size
- **4 languages:** English, Türkçe, Deutsch, العربية (with right-to-left layout)
- **No account, no ads, works offline:** data is stored locally in a SQLite database

## Tech

- Flutter / Dart, Material 3
- State management: [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod)
- Local database: [`drift`](https://pub.dev/packages/drift) (SQLite)
- Notifications and alarms: [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications), [`timezone`](https://pub.dev/packages/timezone), [`flutter_timezone`](https://pub.dev/packages/flutter_timezone), [`android_intent_plus`](https://pub.dev/packages/android_intent_plus)
- Localisation: Flutter `gen-l10n` with ARB files (`lib/l10n`)
- Other: `shared_preferences`, `url_launcher`, `flutter_launcher_icons`

## Project structure

```
lib/
  core/               Shared helpers, theme
  data/               Drift database (profiles, medications, reminders, intake logs)
  notifications/      Scheduling, notification actions, background handler
  features/
    home/             Home screen and calendar strip
    medications/      Add / edit medicine form
    profiles/         Profile management
    onboarding/       First-run introduction
    settings/         Settings (language, privacy policy link)
    alarm/            Full-screen alarm screen
  l10n/               ARB translation files (en, tr, de, ar)
```

## Getting started

Requirements: Flutter SDK (stable), Android SDK with NDK, an Android device or emulator.

```bash
flutter pub get
flutter run
```

On Android, reliable reminders need these permissions, which the app asks for:

- Notifications (Android 13+)
- Exact alarms
- Full-screen intent (for alarm mode)

Some phone makers (Xiaomi, Huawei, Samsung and others) restrict background apps. If reminders arrive late, exclude the app from battery optimisation.

### Localisation

Translations are ARB files in `lib/l10n/`. Run `flutter gen-l10n` (or just `flutter run`) after editing them. `l10n.yaml` is configured in the project root and `generate: true` is set in `pubspec.yaml`.

### Release build

Signing uses `android/key.properties`, which is **not** part of this repository. Create it locally:

```properties
storePassword=...
keyPassword=...
keyAlias=...
storeFile=/path/to/your-keystore.jks
```

Then:

```bash
flutter build appbundle
```

The bundle is created at `build/app/outputs/bundle/release/app-release.aab`. Keep your keystore and `key.properties` out of version control.

## Privacy

All data stays on your device. The app has no account, no analytics and no ads. Privacy policy: **[add your policy URL here]**.

## Author

Maez
