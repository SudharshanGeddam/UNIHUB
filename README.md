# UniHub

UniHub is an AI-powered study assistant application built with Flutter. It combines task management, study planning, and AI assistance into a single campus companion app.

## Features

### ✅ Fully Functional
- **Authentication**: Secure login via Email/Password and Google Sign-In (Firebase Auth).
- **AI Chat Assistant**: Integration with Gemini AI for educational Q&A. Supports text, images, and uploading PDF documents for context-aware answers.
- **Study Planner**: Generates personalized weekly study schedules using AI based on user topics and hours.
- **Notes Scanner**: Uses vision capabilities to scan handwritten notes, transcribe them, and generate summaries, flashcards, and quizzes. Can export results to PDF.
- **Profile Management**: User details and convenient account management.

### 🚧 Prototype / UI-Only
- **Smart Reminders**: Specialized content-aware reminders system (UI implemented).
- **Community Feed**: A space for students to share resources and updates (UI implemented).

## Tech Stack

- **Flutter**: Dart-based cross-platform framework (Material Design 3).
- **Firebase**:
  - Auth: User identity management.
  - Firestore: Cloud database for storing user profiles and study data.
- **AI & ML**: Google Gemini (`google_generative_ai`) for generative text and vision tasks.
- **PDF & File Handling**:
  - `syncfusion_flutter_pdf`: For extracting text from uploaded PDFs.
  - `pdf` & `printing`: For generating downloadable study guides.
  - `file_picker` & `image_picker`: For local media selection.
- **Markdown**: `flutter_markdown` for rendering rich AI responses.

## Architecture

The `lib/` directory is organized to cleanly separate application concerns:
- `config/`: Application-wide settings, themes, and route definitions.
- `data/`: Data models, repositories, and local storage mechanisms.
- `models/`: Plain Dart objects representing core domain entities.
- `pages/` / `screens/`: UI views representing complete screens in the app.
- `services/`: Interfaces with external APIs (Firebase, Gemini) and complex business logic.
- `main.dart`: Application entry point and initialization logic.

## Setup & Configuration

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Firebase Project with Auth and Firestore enabled
- Gemini API Key

### Installation

1. Clone the repository and install dependencies:
   ```bash
   flutter pub get
   ```

2. **Firebase Configuration**:
   - The app uses `firebase_options.dart` for cross-platform initialization.
   - For native plugins, ensure `android/app/google-services.json` (Android) and `ios/Runner/GoogleService-Info.plist` (iOS) are present in your local environment.

3. **Keystore (Release Builds)**:
   - Copy `android/keystore.properties.example` to `android/keystore.properties`.
   - Fill in your signing key details.

### Running the App

This project uses compile-time variables (`--dart-define`) to securely inject API keys. You **must** provide your Gemini API key when running or building the app.

**Debug Mode:**
```bash
flutter run --dart-define=GEMINI_API_KEY="your_actual_api_key_here"
```

**Release Build:**
```bash
flutter build apk --release --dart-define=GEMINI_API_KEY="your_actual_api_key_here"
```

### Note on Security
- API keys are no longer hardcoded in the source.
- Debug logs are stripped in release mode.
- Android backups are disabled to prevent data leakage.

## Known Limitations
To provide transparency regarding the current state of the application:
- **Offline Mode**: Currently, the app requires an active internet connection. Offline caching for notes and schedules is not fully supported.
- **Community Feed & Reminders**: These sections are functional as UI prototypes. Backend integration and notification scheduling are planned for future updates.
- **Data Sync**: While Firebase stores user data, real-time cross-device synchronization might experience slight delays during complex AI operations.

## Continuous Integration
To ensure the codebase remains stable, run the following commands before committing:
```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
```
