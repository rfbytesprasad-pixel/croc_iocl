# croc_iocl_atos


Flutter Android application. This README documents the toolchain, project structure, and the exact commands needed to build, sign, and distribute the APK.


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## 1. Project Overview

- **App name (display):** `<App Display Name>`
- **Application ID:** `com.example.croc_iocl_atos`
- **Namespace:** `com.example.croc_iocl_atos`
- **Platform:** Android
- **Framework:** Flutter

---

## 2. Toolchain Versions

| Tool | Version |
|---|---|
| Flutter | `<x.y.z>` |
| Dart | `<x.y.z>` |
| Java (JDK) | 17 |
| Gradle | `<x.y.z>` |
| Android Gradle Plugin | `<x.y.z>` |
| Kotlin | `<x.y.z>` |
| Android NDK | `27.0.12077973` |
| VS Code | `<x.y.z>` |

**Environment variables:**

- `ANDROID_HOME` → Android SDK path
- `JAVA_HOME` → JDK 17 path

Verify:
```bash
flutter doctor -v
adb devices

3. Project Structure
croc_iocl_atos/
├── pubspec.yaml
├── android/
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/AndroidManifest.xml
│   ├── settings.gradle
│   └── key.properties
├── lib/
└── build/app/outputs/flutter-apk/

4. First-Time Setup
flutter pub get
flutter doctor -v

5. Change App Display Name
Edit android/app/src/main/AndroidManifest.xml:

xml
<application
    android:label="Your New App Name"
    android:icon="@mipmap/ic_launcher">
Or use a string resource in android/app/src/main/res/values/strings.xml:

xml
<string name="app_name">Your New App Name</string>
6. Version Numbers
Edit in pubspec.yaml:

yaml
version: 1.0.0+1
1.0.0 = versionName

1 = versionCode

7. Building the APK
Debug build
bash
flutter clean
flutter pub get
flutter build apk --debug
Output: build/app/outputs/flutter-apk/app-debug.apk

Release build
bash
flutter clean
flutter pub get
flutter build apk --release
Output: build/app/outputs/flutter-apk/app-release.apk

Split per ABI
bash
flutter build apk --release --split-per-abi
Output: app-armeabi-v7a-release.apk, app-arm64-v8a-release.apk, app-x86_64-release.apk

App Bundle
bash
flutter build appbundle --release
Output: build/app/outputs/bundle/release/app-release.aab

8. Release Signing
Create keystore
bash
keytool -genkey -v -keystore ~/croc-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias croc-key
android/key.properties
properties
storePassword=<password>
keyPassword=<password>
keyAlias=croc-key
storeFile=/absolute/path/to/croc-release-key.jks
Add to .gitignore:

text
android/key.properties
*.jks
*.keystore
android/app/build.gradle
Above android {:

gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
Inside android {:

gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
9. Send APK via WhatsApp
Zip it
bash
cd build/app/outputs/flutter-apk/
zip app-release.zip app-release.apk
Send app-release.zip as a Document.

Recipient steps:

Download the zip

Extract it

Tap the APK

Allow "Install unknown apps"

Install

Alternative: rename
bash
cp app-release.apk app-release.apk.txt
Integrity check
bash
sha256sum app-release.apk
10. Full Command Reference
bash
flutter --version
flutter doctor -v
flutter pub get
flutter clean
flutter build apk --debug
flutter build apk --release
flutter build apk --release --split-per-abi
flutter build appbundle --release
flutter devices
flutter run
adb install -r build/app/outputs/flutter-apk/app-release.apk
cd android && ./gradlew --version
cd android && ./gradlew clean
cd android && ./gradlew assembleDebug
cd android && ./gradlew assembleRelease
cd android && ./gradlew signingReport
11. Troubleshooting
Problem	Fix
App not installed	Uninstall old app, reinstall
WhatsApp rejects APK	Zip it first
Gradle build fails	flutter clean && flutter pub get
NDK not found	Install NDK 27.0.12077973
JAVA_HOME not set	Set to JDK 17 path
SDK licenses not accepted	flutter doctor --android-licenses
APK too big	Use --release or --split-per-abi
12. Security Notes
Debug APKs use a shared public key — not for production

Never commit key.properties or *.jks

Never hardcode secrets in the app — APKs are trivially extractable

Verify received APKs with SHA-256

Sideloading is a known malware vector


## Session: 2026-09-25

### Fixed
- Probe never fired (HomePage not mounted during probe state)
- SplashScreen fired LoadRoDetails prematurely
- roautoid hardcoded to 166616 — now reads from /pump fallback
- Tank baseUrl stale — now reads fresh each request
- RO Code expandable section added

### Verified working
- Probe finds ESP at .101
- /roconfig loads, DU list populates
- Home shows RO Code 166616
- Preset screen dropdowns work
- Pumps tab shows live data

### Open
- DU number on pump card (awaiting senior's input on source)
- Backend `/tankstatus` down at site
- roautoid fallback untested at senior's site (no /roconfig there)