# Ticket Stash 🎫✨

**Ticket Stash** is a sleek, modern Flutter application designed to help travelers securely save and manage their transit tickets. Whether it's a PDF e-ticket or a photo of a physical pass, Ticket Stash keeps everything organized and accessible.

![App Icon](assets/icon/app_icon.png)

## 🚀 Features

- **Multi-Format Support**: Save both **PDFs** and **Images** (JPEG, PNG) directly to local storage.
- **Smart Search**: Quickly find tickets by Train Name or Station names using the persistent search bar.
- **Date Range Filter**: Filter your journeys by specific date ranges with a clean, themed UI.
- **Auto-Capitalization**: Smart input fields that ensure your station and train names look professional.
- **Modern Aesthetics**: A premium light blue theme with smooth gradients, floating snackbars, and Cupertino-style interactions.
- **Secure Local Storage**: Everything is saved locally on your device using SQLite—no internet required.
- **Quick View**: Open your tickets instantly in your device's default viewer.

## 🛠️ tech Stack

- **Framework**: [Flutter](https://flutter.dev)
- **State Management**: [Riverpod](https://riverpod.dev)
- **Local Database**: [SQLite (sqflite)](https://pub.dev/packages/sqflite)
- **File Handling**: `file_picker` & `path_provider`
- **Interactions**: `open_filex` for viewing tickets
- **UI Components**: Custom Floating Snackbars, Cupertino Dialogs, and Material Design 3.

## 📦 Setup & Installation

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio / Xcode for native builds

### Steps
1. **Clone the repository**:
   ```bash
   git clone <repository_url>
   cd ticket_stash
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate App Icons** (if modified):
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

4. **Run the application**:
   ```bash
   flutter run
   ```

## 📄 License
This project is for personal use and portfolio demonstration.
