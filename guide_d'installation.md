# Installation and Execution Guide

This guide details how to clone the project, set up the environment, and run the application from the source code across three platforms: Android, iOS, and Web.

---

## 1. Prerequisites

Before you begin, ensure you have the following installed on your machine:
- [Git](https://git-scm.com/downloads)
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- An IDE such as [Android Studio](https://developer.android.com/studio) or [Visual Studio Code](https://code.visualstudio.com/) with Flutter/Dart extensions installed.

Verify your Flutter installation by running the following command in your terminal:
```bash
flutter doctor
```
Ensure there are no issues with the platforms you intend to build for.

---

## 2. Clone the Project

Open your terminal or command prompt and run the following commands to clone the repository to your local machine:

```bash
git clone <REPOSITORY_URL>
cd Park-it
```
*(Note: Replace `<REPOSITORY_URL>` with the actual Git repository link).*

Once inside the project directory, navigate to the `src` folder (if applicable) and install all required Flutter dependencies:
```bash
cd src
flutter pub get
```

---

## 3. Running the Application

You can test the application on Android, iOS, or Web. Use the `flutter run` command to launch the app. 

### Web (Chrome)
To run the app on the web (Google Chrome), you need to specify a specific port. This is required because **Google Authentication** is configured to only work on port `3000`.

Run the following command:
```bash
flutter run -d chrome --web-port 3000
```
Alternatively, if you run `flutter run` without target arguments, it will list available devices. You can type `2` (or the number corresponding to Chrome) to select it, but we highly recommend running the specific command above to ensure the port is correctly set for Google Auth to work.

### Android
To test the app on Android, you must have an active device or emulator:
1. **Physical Device**: Connect an Android phone to your machine via USB/Wi-Fi and ensure **Developer Mode** and **USB Debugging** are enabled on the phone.
2. **Android Emulator**: Open Android Studio and launch a preset Android Virtual Device (AVD).

Once the device is connected or the emulator is running, execute:
```bash
flutter run
```
Select the Android device from the list of available devices if prompted.

### iOS
*(Note: Building for iOS requires a Mac machine with Xcode installed).*
To test the application on iOS:
1. **Physical Device**: Connect your iPhone to your Mac via USB and trust the computer. You may need to configure a signing profile via Xcode first.
2. **iOS Simulator**: Launch the iOS Simulator from Xcode.

Once the device/simulator is running, execute:
```bash
flutter run
```
Select your iOS device or simulator from the list.

---

## Troubleshooting

- **Google Auth fails on Web**: Make sure you used `--web-port 3000` when running the web application. Port mismatch is the #1 reason for sign-in failures.
- **No devices found**: Ensure your phone is connected properly, USB debugging is enabled, or that your simulator/emulator is actively running *before* executing `flutter run`. You can verify connected devices by running `flutter devices`.
- **Missing dependencies**: Run `flutter pub get` inside the directory containing the `pubspec.yaml` file to ensure all libraries are installed.
