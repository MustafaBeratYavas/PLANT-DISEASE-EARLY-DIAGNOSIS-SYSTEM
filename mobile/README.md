<div align="center">
  <br>
  <img src="assets/images/branding/app_logo.png" width="500" alt="GreenHealer Logo">
  <h1>GREENHEALER MOBILE APP</h1>
  <p>
    <strong>GreenHealer:</strong> Offline & Real-time Plant Pathology on the Edge
  </p>

  <p>
    <a href="https://flutter.dev/">
      <img src="https://img.shields.io/badge/Flutter-3.19+-02569B?logo=flutter&logoColor=white" alt="Flutter">
    </a>
    <a href="https://dart.dev/">
      <img src="https://img.shields.io/badge/Dart-3.2+-0175C2?logo=dart&logoColor=white" alt="Dart">
    </a>
    <a href="https://www.tensorflow.org/lite">
      <img src="https://img.shields.io/badge/TFLite-Int8_Quantized-FF6F00?logo=tensorflow&logoColor=white" alt="TFLite">
    </a>
    <a href="https://developer.android.com/">
      <img src="https://img.shields.io/badge/Android-API_26+-3DDC84?logo=android&logoColor=white" alt="Android">
    </a>
    <a href="https://developer.apple.com/ios/">
      <img src="https://img.shields.io/badge/iOS-15+-000000?logo=apple&logoColor=white" alt="iOS">
    </a>
    <a href="../LICENSE">
      <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License">
    </a>
    <img src="https://img.shields.io/badge/Version-1.0.0-blue.svg" alt="Version">
  </p>
</div>

The GreenHealer mobile application delivers a **fully offline, on-device** plant disease diagnosis experience powered by a **quantized MobileNetV3-Large** TensorFlow Lite model. Engineered for frontline agricultural environments with limited connectivity, it provides **real-time inference** across **38 disease classes** covering **14 crop species** — all without requiring an internet connection or cloud infrastructure.

The application is built with a **feature-first architecture**, leveraging dependency injection via **get_it** for clean service management, and supports **full localization (English & Turkish)** for accessible deployment across diverse farming communities.

## Table of Contents
- [Features](#features)
- [On-Device AI Pipeline](#on-device-ai-pipeline)
- [Quick Start](#quick-start)
- [Build & Deployment](#build--deployment)
- [Limitations](#limitations)

<details>
<summary><b>Click to expand project structure details</b></summary>

```text
lib/
├── main.dart                # App entry point & service initialization
├── config/                  # Application-wide configuration
│   ├── routes.dart          # Navigation route definitions
│   └── theme.dart           # Material Design theme & color scheme
├── core/                    # Shared foundation layer
│   ├── constants/           # App-wide constants & configuration values
│   ├── di/                  # Dependency injection (get_it) setup
│   ├── errors/              # Custom error types & exception handling
│   ├── l10n/                # Localization (EN/TR) resources
│   ├── utils/               # Helper functions & extensions
│   └── widgets/             # Reusable UI components
├── data/                    # Data layer
│   ├── data_sources/        # Local data access (JSON, SharedPreferences)
│   ├── models/              # Data models & entities
│   └── repositories/        # Repository pattern implementations
├── features/                # Feature modules (UI + logic)
│   ├── diagnosis/           # Camera capture & AI inference results
│   ├── history/             # Scan history management & timeline
│   ├── library/             # Disease encyclopedia & treatment guides
│   ├── main/                # Main navigation shell
│   ├── settings/            # App preferences & language selection
│   └── splash/              # Animated launch screen
└── services/                # Business logic services
    ├── ai/                  # TFLite model loading & inference pipeline
    ├── media/               # Camera & image picker integration
    └── storage/             # Persistent storage (SharedPreferences)
```

</details>

<details>
<summary><b>Click to expand technology stack details</b></summary>

| Component | Technology | Purpose |
|:---|:---|:---|
| Framework | Flutter 3.19+ | Cross-platform UI toolkit |
| Language | Dart ≥ 3.2 | Application logic & type safety |
| AI Runtime | tflite_flutter | On-device TFLite model inference |
| Image Capture | image_picker | Camera & gallery integration |
| Image Processing | image | Preprocessing for model input |
| DI Container | get_it | Service locator / dependency injection |
| Local Storage | shared_preferences | Persistent key-value storage |
| Typography | google_fonts | Premium font management |
| Permissions | permission_handler | Runtime permission management |
| File System | path_provider | Platform-specific directory access |
| App Info | package_info_plus | Version & build metadata |
| Localization | flutter_localizations + intl | Multi-language support (EN/TR) |

</details>

## Features

The application provides a comprehensive suite of tools specifically designed for **field-ready plant diagnostics** in real-world agricultural environments. Each feature has been carefully engineered to address the practical challenges faced by farmers and agronomists operating in regions with **limited technological infrastructure**, ensuring that advanced AI-driven pathological analysis remains accessible, intuitive, and actionable regardless of connectivity constraints or technical expertise.

| Feature | Description |
|:---|:---|
| **Real-Time Diagnosis** | On-device classification across **38 disease classes** using quantized MobileNetV3 with **~5.58 ms** inference latency |
| **Disease Library** | Curated encyclopedia with detailed symptoms, evidence-based treatment protocols, and layered prevention strategies |
| **Scan History** | Persistent timeline tracking of all diagnoses with timestamps, confidence scores, and result archiving |
| **Multi-Language** | Full localization support for English and Turkish with extensible i18n architecture |
| **Fully Offline** | **Zero network dependency** — all AI inference and data access runs entirely on-device |
| **Adaptive UI** | Material Design 3 with custom theming, smooth animations, and responsive layouts |

## On-Device AI Pipeline

The AI inference pipeline is managed through the **services/ai/** module, which serves as the central bridge between the Flutter user interface and the underlying **TensorFlow Lite runtime**. The module encapsulates the entire lifecycle of a diagnostic request — from raw image acquisition through **tensor preprocessing**, **quantized model inference**, and **probabilistic classification** — delivering results to the presentation layer with **minimal latency** and **zero network overhead**. This architecture ensures that the diagnostic capability remains fully self-contained within the application sandbox, enabling reliable operation regardless of device connectivity.

| Asset | Path | Description |
|:---|:---|:---|
| TFLite Model | assets/models/ | **Int8 quantized** MobileNetV3-Large (**~3 MB**) |
| Class Labels | assets/labels.txt | 38 plant disease class identifiers |
| Disease Data | assets/data/ | JSON files with treatment & prevention information |

When a diagnostic request is initiated, these assets are orchestrated through a **five-stage inference pipeline**. Each stage is designed as an isolated, testable unit within the service layer, ensuring that the flow from raw pixel data to actionable diagnosis remains **deterministic and reproducible** across devices:

| Stage | Process | Technical Detail |
|:---|:---|:---|
| 1. Capture | Image acquisition | User captures or selects a leaf image via **services/media/** |
| 2. Preprocessing | Tensor preparation | Image is resized to **224×224** and normalized for MobileNetV3 input |
| 3. Inference | Model execution | The **tflite_flutter** interpreter runs **Int8 quantized** inference on the preprocessed tensor |
| 4. Classification | Result extraction | Top-k predictions with confidence scores are extracted and mapped to disease labels |
| 5. Presentation | Result display | The **features/diagnosis/** module presents the diagnosis with treatment recommendations |

## Quick Start

### Prerequisites

* **Flutter SDK:** Version 3.19 or higher. Verify with `flutter --version`.
* **Dart SDK:** Version ≥ 3.2.0 (bundled with Flutter SDK).
* **Android SDK:** API Level 26+ (Android 8.0 Oreo). Verify with `flutter doctor`.
* **Xcode (iOS only):** Version 15+ with a valid Apple Developer certificate.
* **Device:** Physical Android/iOS device or configured emulator/simulator.

---

```bash
# Verify that all required SDKs and toolchains are configured
flutter doctor

# Fetch all Dart packages defined in pubspec.yaml
flutter pub get

# Launch application on a connected device (debug mode)
flutter run

# Run unit & widget tests
flutter test

# Run tests with coverage report
flutter test --coverage

# Static analysis (lint rules)
flutter analyze
```

## Build & Deployment

Production-ready builds for distribution across **Android** and **iOS** platforms.

```bash
# Android — Standard APK (direct installation / sideloading)
flutter build apk --release

# Android — App Bundle (Google Play Store distribution)
flutter build appbundle --release

# iOS — Release build (requires macOS + Xcode 15+ + Apple Developer certificate)
flutter build ios --release
```

### Build Artifacts

| Platform | Format | Output Path |
|:---|:---|:---|
| Android | APK | `build/app/outputs/flutter-apk/app-release.apk` |
| Android | AAB | `build/app/outputs/bundle/release/app-release.aab` |
| iOS | Runner.app | `build/ios/iphoneos/Runner.app` |

> **Important:** Ensure the **TFLite model** (`assets/models/`) and **label file** (`assets/labels.txt`) are present before building. The application will not function without these on-device inference assets.

## Limitations

> **Important:** This section outlines the current operational boundaries of the mobile application.

* **Platform Support:** The application has been primarily tested on **Android** devices. iOS deployment requires additional provisioning and has not been validated on all device models.
* **Supported Classes:** The TFLite model is trained on the **PlantVillage dataset** and is limited to **14 crop species** and **38 disease classes**. Plants or diseases outside this scope will produce unreliable predictions.
* **Camera Quality:** Diagnosis accuracy is dependent on **image quality**. Low-resolution cameras, motion blur, or poor lighting conditions may degrade classification confidence.
* **Model Updates:** The bundled TFLite model is static. There is currently **no over-the-air (OTA) model update** mechanism — model upgrades require a new app release.
* **Storage:** Scan history is stored locally via **SharedPreferences**. Clearing app data will permanently delete all diagnosis history.
