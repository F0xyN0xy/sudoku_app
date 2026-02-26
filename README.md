# 🧩 Sudoku App

A personal Flutter Android app that generates unlimited Sudoku puzzles — because the market only sells one a week.

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?logo=flutter&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)
![Release](https://img.shields.io/github/v/release/f0xyn0xy/sudoku-app?color=blue)

📲 **[Download latest APK →](https://github.com/f0xyn0xy/sudoku_app/releases/latest)**

---

## Features

| Feature | Description |
|---|---|
| 🎲 **Puzzle Generator** | 4×4 mini or 9×9 classic, three difficulty levels |
| 🔖 **Unique IDs** | Every puzzle gets a short 8-character ID (e.g. `AB12CD34`) |
| 🖊️ **Play on-screen** | Tap cells, enter numbers, no hints until you're done |
| ✅ **Check your work** | Only unlocks once every cell is filled — shows mistakes in red with the correct answer |
| 🖨️ **PDF export** | Print 1 or 2 puzzles per page, optionally with solution pages |
| 📤 **Share** | Send the PDF via email, WhatsApp, or any app |
| 🔍 **Solution lookup** | Type a puzzle ID in the Solutions tab to reveal its answer |
| 📋 **Copy ID** | Tap the ID on any saved puzzle to copy it instantly |
| 💾 **Local storage** | All puzzles and solutions are saved on-device, nothing goes to a server |

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.0
- Android Studio or VS Code with the Flutter & Dart extensions
- An Android device or emulator (Android 5.0+)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-username/sudoku-app.git
cd sudoku-app

# 2. Install dependencies
flutter pub get

# 3. Run on your connected device
flutter run
```

### Build a release APK

```bash
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk` — ready to install directly on any Android phone.

---

## How It Works

### Puzzle Generation
Puzzles are generated using a **backtracking algorithm with bitmask validation** (O(1) per cell check), running in a **background isolate** so the UI never freezes. A random seed is used each time to guarantee a unique puzzle.

### Puzzle IDs
Each puzzle is assigned a UUID internally. The **short ID** shown to the user is the first 8 characters uppercased (e.g. `AB12CD34`). The full solution is stored alongside the puzzle locally, so entering the ID in the Solutions tab will always retrieve it.

### Storage
Uses `SharedPreferences` to persist puzzles as JSON on the device. No internet connection or account required.

### PDF Export
Uses the [`pdf`](https://pub.dev/packages/pdf) and [`printing`](https://pub.dev/packages/printing) packages to generate clean printable layouts. The puzzle ID is printed on every page so the solution can always be looked up.

---

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   └── sudoku_puzzle.dart             # Puzzle data model + JSON serialization
├── services/
│   ├── sudoku_generator.dart          # Isolate-based backtracking generator
│   ├── puzzle_storage.dart            # Local persistence (SharedPreferences)
│   └── pdf_service.dart               # PDF layout and generation
├── screens/
│   ├── home_screen.dart               # Bottom navigation shell
│   ├── generate_screen.dart           # New puzzle settings screen
│   ├── play_screen.dart               # Interactive puzzle solving
│   ├── history_screen.dart            # Saved puzzles list
│   ├── print_options_screen.dart      # Print / share options
│   └── solution_lookup_screen.dart    # Look up solution by ID
└── widgets/
    └── sudoku_grid_widget.dart        # Reusable interactive/display grid
```

---

## Dependencies

| Package | Purpose |
|---|---|
| [`shared_preferences`](https://pub.dev/packages/shared_preferences) | Local puzzle storage |
| [`pdf`](https://pub.dev/packages/pdf) | PDF generation |
| [`printing`](https://pub.dev/packages/printing) | Print & share PDFs |
| [`share_plus`](https://pub.dev/packages/share_plus) | Native share sheet |
| [`uuid`](https://pub.dev/packages/uuid) | Unique puzzle ID generation |
| [`path_provider`](https://pub.dev/packages/path_provider) | File system access |

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.