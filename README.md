# ZenFlector - Soothing Sounds and Meditation App

[![Flutter](https://img.shields.io/badge/Flutter-Framework-blue?logo=flutter)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-orange?logo=firebase)](https://firebase.google.com/)
[![Dart](https://img.shields.io/badge/Dart-Language-blueviolet)](https://dart.dev/)
[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

## Overview

ZenFlector is a cross-platform mobile application (Android and iOS) built with Flutter and Firebase.  It's designed to help users improve sleep, reduce stress, and enhance relaxation through a curated library of audio content.  The app features guided meditations, hypnotic stories, nature sounds, and more, organized into user-friendly categories.  A separate React/Vite-based admin panel allows for easy content management.

## Features

*   **Audio Playback:** High-quality audio streaming with background playback and system notification controls (using `just_audio` and `just_audio_background`).
*   **Genres:**  Audio content organized into categories (e.g., "Deep Sleep," "Meditation," "Mindset").
*   **Playlists:**  Users can create and manage custom playlists.
*   **Favorites:** Users can mark audio tracks as favorites.
*   **User Accounts:**  User registration and login via Firebase Authentication (email/password).
*   **Profile Management:**  Users can update their name and profile picture.
*   **Dark Mode:**  Switch between light and dark themes.
*   **Search:**  Search functionality to find specific audio tracks.
*   **Bluetooth Device Display:** Shows the currently connected Bluetooth device (via system settings).
*   **Admin Panel (Web):** A separate React/Vite application for managing genres and uploading audio content to Firebase Storage and Firestore.
*   **Responsive Design:** Adapts to different screen sizes (phones and tablets).

## Technologies

*   **Frontend:** Flutter (Dart)
*   **Backend:** Firebase (Firestore, Storage, Authentication)
*   **State Management:** Provider
*   **Audio Playback:** `just_audio`, `just_audio_background`
*   **Image Handling:** `cached_network_image`, `image_picker`, `image_cropper`
*   **Navigation:** Flutter's built-in navigation
*   **Other Packages:** `rxdart`, `equatable`, `path_provider`, `flutter_blue_plus`, `shared_preferences`, `package_info_plus`, `url_launcher`, `uuid`
*  **Admin Panel:** React, Vite, Material UI, `react-hook-form`, `react-router-dom`

## Project Structure
*   **`android/` and `ios/`:**  Platform-specific code (Android and iOS). Contains `AndroidManifest.xml`, configurations.
*   **`lib/`:** Main Flutter application code.
    *   **`api/`:**  Firebase interaction logic (`firebase_service.dart`).
    *   **`components/`:** Reusable UI widgets (e.g., `AudioCard`, `GenreCard`, `SectionHeader`).
    *   **`models/`:** Data model classes (e.g., `Audio`, `Genre`, `Playlist`, `User`).
    *   **`providers/`:** State management using the `provider` package.
    *   **`screens/`:** Individual screens of the app (e.g., `HomeScreen`, `GenreScreen`, `SettingsScreen`).
    *   **`themes/`:**  Theme definitions (`app_theme.dart`).
    *   **`utils/`:**  Utility classes and constants (`constants.dart`).
    *   **`widgets/`:** Custom widgets like the `SeekBar` and `AudioListItem`.
    *   **`main.dart`:** Application entry point.
    * **`firebase_options.dart`:** Firebase configurations.

## Setup Instructions

1.  **Clone the Repository:**
    ```bash
    git clone [Your Repository URL]
    cd zenflector
    ```

2.  **Flutter Setup:**
    *   Ensure you have Flutter and Dart SDKs installed.
    *   Install Flutter dependencies:
        ```bash
        flutter pub get
        ```

3.  **Firebase Setup:**
    *   Create a Firebase project in the Firebase console ([https://console.firebase.google.com/](https://console.firebase.google.com/)).
    *   Enable **Firebase Authentication** (Email/Password).
    *   Enable **Cloud Firestore** and create the following collections:
        *   `users`: (fields as described in `user.dart`)
        *   `genres`: (fields as described in `genre.dart`)
        *   `audio`: (fields as described in `audio.dart`)
        *   `playlists`: (fields as described in `playlist.dart`)
    *   Enable **Firebase Storage**.  Create the following folder structure:
        ```
        audio/
            [genreId1]/
                audio_file_1.mp3
                audio_file_2.mp3
                ...
            [genreId2]/
                ...
        genre_images/
           genre_image.jpg
        user_profiles/
            [userId1]/
              profile_image.jpg
            [userId2]/

        ```
    * **Set up CORS on your Firebase Storage bucket.** This is *essential* for the web admin panel to work.  Use the `gsutil` command-line tool (part of the Google Cloud SDK):

       ```bash
        gsutil cors set cors-config.json gs://your-bucket-name
        ```
      Create `cors-config.json` file:
      ```json
        [
          {
            "origin": ["http://localhost:3000", "http://localhost:5173", "[https://example.com](https://example.com)"],
            "method": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
            "responseHeader": [
              "Content-Type",
              "Authorization",
              "Content-Length",
              "x-firebase-storage-version",
              "x-goog-upload-protocol",
              "x-goog-upload-url",
              "x-goog-resumable"
            ],
            "maxAgeSeconds": 3600
          }
        ]
        ```
        Replace `https://zenflector-admin.vercel.app` with your *actual* Vercel deployment URL (or the URL where your admin panel is hosted).  Include `localhost` URLs for local development.
    *   Add Android and iOS apps to your Firebase project.
    *   Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) and place them in the appropriate directories (`android/app` and `ios/Runner`, respectively).
    *  Run the flutterfire configure command:
    ```
     flutterfire configure
    ```

4. **Android Permissions:**
   *  Add required permissions in `AndroidManifest.xml` for, internet, bluetooth and for background services.
   *  Add service and receiver, for `just_audio_background`.
   * Add activity for `image_cropper` plugin.
5. **iOS Permissions:** Add required permissions in `info.plist`.

6.  **Run the App:**
    ```bash
    flutter run
    ```

**Admin Panel Setup (React/Vite - Separate Project):**

1.  Navigate to the `zenflector-admin` directory.
2.  Install dependencies: `npm install`
3.  Ensure your Firebase configuration in `src/firebase.js` is correct.
4.  Run the admin panel: `npm run dev`

**Note:** Remember to replace placeholder values (app icon, privacy policy URL, terms of service URL, company name, etc.) with your actual information.  Also, the provided Privacy Policy and Terms of Service are *samples only* and should be reviewed and modified by a legal professional.

This README provides a solid starting point for your GitHub repository.  It covers the key aspects of your project, making it easy for others (and your future self!) to understand and get started.  Good luck with ZenFlector!
