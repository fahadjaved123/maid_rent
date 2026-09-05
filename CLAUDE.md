# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

- **Dependencies**: `flutter pub get`
- **Linting**: `flutter analyze`
- **Testing**:
  - All tests: `flutter test`
  - Single test: `flutter test test/path_to_test.dart`
- **Execution**: `flutter run`
- **Build**: `flutter build apk` (Android) or `flutter build ios` (iOS)

## High-Level Architecture

The project follows a layered architecture designed for a role-based marketplace (Households vs. Maids).

### 1. Layer Responsibility
- **UI Layer (`lib/screens`, `lib/widgets`)**: 
  - Screens are organized by user role (`household/`, `maid/`) and common functionality (`auth/`, `shared/`, `splash/`).
  - Reusable UI components are centralized in `lib/widgets`.
- **State Management Layer (`lib/providers`)**: 
  - Uses the `provider` package to manage app state and business logic.
  - Providers act as the intermediary between the UI and Services.
- **Service Layer (`lib/services`)**: 
  - Provides an abstraction over Firebase infrastructure:
    - `auth_service.dart`: Firebase Authentication.
    - `firestore_service.dart`: Cloud Firestore CRUD operations.
    - `storage_service.dart`: Firebase Storage for file uploads.
- **Model Layer (`lib/models`)**: 
  - Defines the data structures for the application (e.g., `user_model.dart`, `booking_model.dart`).

### 2. Core Configurations
- **Routing**: Centralized route definitions are located in `lib/config/routes.dart`.
- **Theming**: Global theme and styling are defined in `lib/config/theme.dart`.
- **Constants**: App-wide constants are stored in `lib/config/constants.dart`.

### 3. Data Flow
`UI (Screens/Widgets)` $\rightarrow$ `Providers (State/Logic)` $\rightarrow$ `Services (Firebase API)` $\rightarrow$ `Firestore/Auth/Storage`
