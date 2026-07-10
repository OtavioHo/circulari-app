# Circulari App Monorepo

This repository is a Flutter monorepo containing the main app and internal packages.

## Workspace structure

- `.`: main Flutter application
- `packages/circulari_ui`: internal UI package (themes and reusable UI building blocks)

## Bootstrap and run

1. `flutter pub get`
2. `flutter run`

If you want to manage all packages with Melos:

1. `dart run melos bootstrap`

## Subscriptions (RevenueCat)

RevenueCat public SDK keys are injected at build time. Copy the template and
fill in the keys from RevenueCat → Project → API keys:

```bash
cp dart_defines.example.json dart_defines.json
flutter run --dart-define-from-file=dart_defines.json
```

`dart_defines.json` is gitignored. See
[docs/subscriptions-testing-android.md](docs/subscriptions-testing-android.md)
for the full end-to-end testing guide on Android.

## Notes

- The app consumes `circulari_ui` via a local path dependency in `pubspec.yaml`.
- Shared theme is exported from `packages/circulari_ui/lib/circulari_ui.dart`.
