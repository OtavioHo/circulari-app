# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get           # Install dependencies
flutter run               # Run on connected device (use -d web, -d ios, -d android to target a platform)
flutter test              # Run all tests
flutter test test/widget_test.dart  # Run a single test file
flutter analyze           # Run Dart static analysis
dart fix --apply          # Auto-fix lint issues
flutter build apk         # Build Android APK (or ios, web, macos, windows, linux)
```

## Architecture

This is a Flutter app targeting iOS, Android, macOS, Windows, Linux, and Web from a shared Dart codebase.

- `lib/` — all application Dart code; entry point is `lib/main.dart`
- `test/` — widget and unit tests using `flutter_test`
- Platform-specific build configurations live in `android/`, `ios/`, `macos/`, `windows/`, `linux/`, `web/` — typically only touched for native integration or build settings

Linting is configured via `analysis_options.yaml` using the `flutter_lints` package defaults.

## State Management

All remote state is managed with `flutter_bloc`. Every widget that makes an API request must have exactly three states: loading, success, and failure. Never call the API directly from a widget — always dispatch a bloc event.

## Adding a New Feature

Each feature lives under `lib/features/<feature_name>/` and follows this structure:

```
features/<name>/
├── <name>_di.dart                      # GetIt extension — registers this feature's deps
├── data/
│   ├── models/<name>_model.dart        # fromJson only, extends the domain entity
│   ├── sources/<name>_remote_source.dart  # raw Dio calls + DioException → AppException mapping
│   └── repositories/<name>_repository_impl.dart  # implements domain interface
├── domain/
│   ├── entities/<entity>.dart          # plain Dart class, no JSON logic
│   ├── repositories/<name>_repository.dart  # abstract interface
│   └── usecases/                       # one file per operation, single call() method
└── presentation/
    ├── bloc/
    │   ├── <name>_state.dart           # sealed class: Initial, Loading, Success, Failure
    │   ├── <name>_event.dart           # sealed class: one final class per user action
    │   └── <name>_bloc.dart
    ├── pages/                          # full screens
    └── widgets/                        # reusable sub-widgets scoped to this feature
```

### State shape

```dart
sealed class <Name>State {}
final class <Name>Initial  extends <Name>State {}
final class <Name>Loading  extends <Name>State {}
final class <Name>Success  extends <Name>State { final Data data; }
final class <Name>Failure  extends <Name>State { final String message; }
```

Use an exhaustive `switch` in the widget so the compiler enforces all states are handled:

```dart
BlocBuilder<<Name>Bloc, <Name>State>(
  builder: (context, state) => switch (state) {
    <Name>Initial()  => const SizedBox.shrink(),
    <Name>Loading()  => const CircularProgressIndicator(),
    <Name>Success(:final data) => MyView(data: data),
    <Name>Failure(:final message) => ErrorView(message: message),
  },
)
```

### Dependency injection

Create `features/<name>/<name>_di.dart` with a `GetIt` extension:

```dart
extension <Name>DI on GetIt {
  void register<Name>Feature() {
    registerLazySingleton<...RemoteSource>(() => ...RemoteSource(call()));
    registerLazySingleton<...Repository>(() => ...RepositoryImpl(call()));
    registerLazySingleton(() => Get<Name>Usecase(call()));
    // ... other usecases
    registerFactory(() => <Name>Bloc(...));  // registerFactory, not Singleton
  }
}
```

Then add one line in `lib/core/di/injection.dart`:

```dart
sl.register<Name>Feature();
```

### Router

Provide the bloc on the route, not at the app root. In `lib/core/router/app_router.dart`:

```dart
GoRoute(
  path: '/<name>',
  builder: (context, state) => BlocProvider(
    create: (_) => sl<<Name>Bloc>()..add(const <Name>LoadRequested()),
    child: const <Name>Page(),
  ),
),
```

### Error handling

`AppException` subtypes live in `lib/core/error/app_exception.dart`. Remote sources must catch `DioException` and rethrow as an `AppException`. Blocs catch `AppException` and emit `<Name>Failure(e.message)`. Raw exceptions must never reach the UI.
