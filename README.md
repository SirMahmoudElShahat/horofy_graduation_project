# Horofy — حروفى

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green)](#)

An interactive Arabic educational mobile app designed to help children with reading and writing difficulties, including **Dyslexia** and **Dysgraphia**.

> 🎓 Graduation project developed by an 8-person team covering Flutter, AI, Backend, and Design.

---

## 📹 Demo Video

🎬 **[Watch the Demo on Google Drive](https://drive.google.com/file/d/1ZN7VORUWNFPovxp8d1no6R_UiK_Oku1R/view?usp=drivesdk)**


---

## Overview

Horofy guides children through **7 progressive interactive levels** that cover letter listening, tracing, spelling, speech recognition, handwriting recognition, and sentence construction. It also includes an AI-powered chat assistant called **Shalby (شلبي)** aimed at parents to help assess and monitor their child's progress.

---

## Features

- **7 progressive learning levels** — from basic letter listening to full word handwriting with dysgraphia detection
- **Shalby AI assistant** — conversational AI chat for parents to evaluate their child's condition
- **Reversed handwriting detection** — geometric ink-flip algorithm that detects dysgraphia indicators
- **Progress tracking** — full REST API integration to record exercise results and resume progress
- **Offline mode** — interactive Arabic letter-ordering drag-and-drop game when no internet is available
- **Child management** — add, edit, and delete child profiles with avatar selection
- **Web dashboard integration** — links parents to a companion web app with a token-authenticated URL

---

## Architecture

The app follows **Clean Architecture** end-to-end:

```
lib/
├── core/
│   ├── cache/          # CacheHelper (SharedPreferences)
│   ├── constants/      # Route names, API endpoints, level names
│   ├── database/       # AppDatabase (SQLite)
│   ├── helper/         # OrientationHelper
│   ├── services/       # MlKitModelService (Singleton)
│   ├── style/          # AppColors, AppTextStyles
│   └── widgets/        # LoadingOverlay, OfflineWrapper, NoInternetConnection
│
└── horofy/
    ├── data/
    │   ├── datasources/   # Remote & Local Data Sources
    │   ├── models/        # Data Models (extend Entities)
    │   └── repositories/  # Repository Implementations
    │
    ├── domain/
    │   ├── entities/      # Pure Business Entities
    │   ├── repositories/  # Abstract Repository Contracts
    │   └── usecases/      # Single-responsibility Use Cases
    │
    └── presentation/
        ├── cubit/         # BLoC/Cubit State Management
        ├── screens/       # UI Screens
        └── widgets/       # Reusable Widgets
```

**Data flow:**
```
Entity → Use Case → Repository (Abstract)
                          ↓
                  Repository (Impl) → Data Source
                          ↓
                       Cubit/BLoC
                          ↓
                       UI Screen
```

---

## The 7 Levels

| Level | Activity | Technology |
|-------|----------|------------|
| **Level 1** | Listen to a letter name, pronounce it, then trace it with your finger | `audioplayers` + `speech_to_text` + Custom Canvas |
| **Level 2** | Learn long-vowel letters (أ، و، ي) with example words (باب، بوق، بيت) | `flutter_tts` + `speech_to_text` |
| **Level 3** | Listen to individual letters, then pronounce the full word | `speech_to_text` |
| **Level 4** | Choose the correct letter from options, then pronounce the word | `speech_to_text` |
| **Level 5** | Write letters and word beginnings with your finger | `ML Kit Digital Ink Recognition` |
| **Level 6** | Build a full sentence by pronouncing it word by word | `speech_to_text` |
| **Level 7** | Write full words with your finger — detects reversed/mirrored writing | `ML Kit` + geometric ink-flip algorithm |

---

## Technical Highlights

### Reversed Handwriting Detection (Dysgraphia Indicator)

Rather than reversing the recognized string output (which is inaccurate), the algorithm geometrically mirrors the ink stroke coordinates on the X-axis before running recognition again. If the flipped version scores higher accuracy, a dysgraphia alarm is triggered.

```dart
Future<String?> _recognizeFlipped() async {
  double maxX = 0;
  for (final stroke in _ink.strokes)
    for (final point in stroke.points)
      if (point.x > maxX) maxX = point.x;

  // Mirror each point: x_new = maxX - x_old
  final flippedInk = ml_ink.Ink();
  for (final stroke in _ink.strokes) {
    final flippedStroke = Stroke();
    for (final point in stroke.points)
      flippedStroke.points.add(
        StrokePoint(x: maxX - point.x, y: point.y, t: point.t),
      );
    flippedInk.strokes.add(flippedStroke);
  }
  final candidates = await _recognizer.recognize(flippedInk);
  return candidates.isNotEmpty ? candidates.first.text : null;
}
```

### ML Kit Model Singleton

The Arabic handwriting recognition model is downloaded and warmed up **once at app startup** via a singleton service, preventing repeated downloads on every screen navigation.

```dart
class MlKitModelService {
  static final MlKitModelService instance = MlKitModelService._();
  bool _isReady = false;
  Future<void>? _downloadFuture;

  Future<void> ensureReady(String languageCode) {
    _downloadFuture ??= _doDownload(languageCode);
    return _downloadFuture!;
  }
}
```

### Level 2 Race Condition Fix

`SubmissionCubit` and `Level2Cubit` can emit their loaded states in either order. The resume logic caches incoming submission data and only applies it once **both cubits are ready**, triggered from both `BlocListener`s via `MultiBlocListener`.

```dart
void _applyResume({SubmissionsLoaded? submissionsState}) {
  if (_resumeApplied) return;
  if (submissionsState != null) _pendingResume = submissionsState;

  final pending = _pendingResume;
  if (pending == null) return;

  final level2State = context.read<Level2Cubit>().state;
  if (level2State is! Level2Loaded) return;

  // Both cubits ready — apply resume
  _resumeApplied = true;
  final nextIndex = level2State.madLetters.indexWhere(
    (l) => !pending.completedExerciseIds('level2').contains(l.id),
  );
  if (nextIndex != -1) context.read<Level2Cubit>().jumpToIndex(nextIndex);
}
```

---

## Tech Stack

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | State management (Cubit/BLoC pattern) |
| `google_mlkit_digital_ink_recognition` | Arabic handwriting recognition |
| `speech_to_text` | Speech recognition |
| `audioplayers` | Audio playback |
| `flutter_tts` | Text-to-speech |
| `dio` | HTTP client |
| `sqflite` | Local SQLite database |
| `shared_preferences` | Token and settings storage |
| `get` | Snackbars and navigation helpers |
| `equatable` | Value equality for state classes |
| `flutter_offline` | Internet connectivity detection |
| `url_launcher` | Opening external links |

---

## Getting Started

### Requirements

- Flutter SDK `^3.10.0`
- Dart SDK `^3.10.0`
- Android Studio or VS Code
- Android or iOS device / emulator

### Run the App

```bash
# Clone the repository
git clone https://github.com/your-username/horofy.git
cd horofy

# Install dependencies
flutter pub get

# Run
flutter run
```

> **Note:** The ML Kit Arabic model is downloaded automatically on first launch and requires an internet connection.

---

## API Reference

Base URL: `https://deslexia-desgraphia-production-6886.up.railway.app`

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/auth/login` | User login |
| `POST` | `/auth/register` | User registration |
| `POST` | `/auth/forgot-password` | Request password reset OTP |
| `POST` | `/auth/verify-otp` | Verify OTP |
| `POST` | `/auth/reset-password` | Reset password |
| `GET` | `/api/children` | Get all children for logged-in parent |
| `POST` | `/api/children` | Add a new child |
| `PUT` | `/api/children/:id` | Update child information |
| `DELETE` | `/api/children/:id` | Delete a child |
| `POST` | `/submissions` | Submit an exercise result |
| `GET` | `/submissions/child/:id` | Get all submissions for a child |
| `GET` | `/chat/conversations` | Get all conversations |
| `POST` | `/chat/conversations` | Create a new conversation |
| `POST` | `/chat/conversations/:id/messages` | Send a message to Shalby |
| `DELETE` | `/chat/conversations/:id` | Delete a conversation |

---

## Database Schema

```sql
CREATE TABLE children (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    remoteId  TEXT,
    name      TEXT,
    birthDate TEXT,
    gender    INTEGER,
    avatar    TEXT,
    level     TEXT DEFAULT 'level1'
);

CREATE TABLE progress (
    id       INTEGER PRIMARY KEY AUTOINCREMENT,
    childId  INTEGER,
    level    TEXT,
    letterId INTEGER,
    listened INTEGER DEFAULT 0,
    spoken   INTEGER DEFAULT 0,
    written  INTEGER DEFAULT 0,
    FOREIGN KEY (childId) REFERENCES children(id)
);
```

---

## Screen Flow

```
Splash Screen
    └── Onboarding (3 slides)
            └── Main Home  ──────────────────────────────────────────┐
                    ├── Parent Home                                   │
                    │       ├── Web Dashboard (token-authenticated)   │
                    │       ├── Shalby Conversations List             │
                    │       │       └── Chat Screen (AI)              │
                    │       ├── Children List                         │
                    │       └── Add / Edit Child                      │
                    └── Child Home                                    │
                            └── Child Levels Screen ─────────────────┘
                                    ├── Level 1 (Listen + Trace)
                                    ├── Level 2 (Long Vowels)
                                    ├── Level 3 (Spelling)
                                    ├── Level 4 (Letter Choice)
                                    ├── Level 5 (Write with ML Kit)
                                    ├── Level 6 (Sentence Building)
                                    └── Level 7 (Write + Dysgraphia Detection)
```

---

## Key Learnings

| Problem | Solution |
|---------|----------|
| Geometric vs string reversal for dysgraphia | Flipping ink stroke coordinates is more accurate than reversing the recognized string |
| ML Kit model re-downloading on navigation | Singleton `MlKitModelService` downloads and warms up the model once at startup |
| Level 2 submission/level state race condition | Cache pending resume data, apply only when both cubits are loaded |
| `pushReplacementNamed` with `Navigator.pop` callback on unmounted context | Capture `NavigatorState` before navigation |
| `Future.delayed` after navigation in speech handlers | Call navigation methods immediately without delay |
| Delete operation ordering | Always fetch `remoteId` before local deletion, never after |

---

## Team

| Role | Responsibility |
|------|---------------|
| Flutter Developer | Full mobile application |
| AI Team | Shalby assistant and language processing |
| Backend Team | REST API and Railway deployment |
| Design Team | UI/UX and visual assets |

---

## License

Private project — all rights reserved.
