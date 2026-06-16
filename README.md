# EdgeVision — On-Device Intelligence & Offline Edge AI

> COMP4310 Mobile Software Development — Birzeit University  
> Group 2 | Assignment #2 Prototype

A Flutter application that performs **real-time object detection entirely on-device** using Google ML Kit — no internet connection required. This prototype demonstrates the core concepts of On-Device Intelligence and Offline Edge AI on Android.

---

## What It Does

Point your phone camera at any object and the app instantly identifies it — drawing bounding boxes, displaying classification labels and confidence scores, and showing the inference time in milliseconds. Everything runs locally on the device with zero cloud communication.

---

## Features

- **Offline object detection** — works with airplane mode on
- **Real-time camera feed** — live bounding boxes rendered on every frame
- **Confidence scores** — shows prediction certainty per detected object (e.g. `Person 94%`)
- **Inference timer** — displays on-device processing time in ms
- **ON-DEVICE badge** — visual indicator confirming no network is used
- **Runtime camera permission** — clean permission flow before camera access

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| ML Engine | Google ML Kit Object Detection |
| Camera | camera package (CameraX) |
| Architecture | MVVM + Repository Pattern |
| State Management | Provider (ChangeNotifier) |
| Permissions | permission_handler |

---

## Architecture

The app follows **MVVM (Model-View-ViewModel)** with a Repository layer, cleanly separating UI, business logic, and ML inference:

```
lib/
├── main.dart                          # App entry point, Provider setup
├── data/
│   ├── models/
│   │   └── detection_result.dart     # DetectionResult model (label, confidence, boundingBox)
│   └── ml_repository.dart            # ML Kit wrapper, YUV→NV21 conversion, inference
├── viewmodel/
│   └── detection_viewmodel.dart      # CameraController lifecycle, frame processing loop
└── view/
    ├── camera_screen.dart            # Camera preview + overlays (UI layer)
    └── widgets/
        └── bounding_box_painter.dart # CustomPainter — draws boxes and labels
```

### Data Flow

```
Camera Frame (YUV_420_888)
        ↓
MLRepository — converts to NV21, feeds ML Kit
        ↓
Google ML Kit — on-device inference (NPU/GPU)
        ↓
DetectionViewModel — updates state via ChangeNotifier
        ↓
CameraScreen — repaints BoundingBoxPainter
        ↓
User sees result in < 30ms
```

---

## Getting Started

### Requirements

- Flutter SDK 3.x+
- Android device or emulator (API 21+)
- Android Studio or VS Code

### Run the App

```bash
# Clone the repo
git clone https://github.com/Okmenahm1/TensorFlow-lite-Prototype.git
cd TensorFlow-lite-Prototype

# Install dependencies
flutter pub get

# Run on connected Android device
flutter run
```

On first launch the app will request camera permission. Grant it and point the camera at any object.

---

## Key Dependencies

```yaml
camera: ^0.11.0                        # Live camera feed via CameraX
google_mlkit_object_detection: ^0.13.0 # On-device ML inference
provider: ^6.1.2                       # MVVM state management
permission_handler: ^11.3.1            # Runtime camera permission
```

---

## Edge AI vs Cloud AI

| Feature | Cloud AI | Edge AI (This App) |
|---|---|---|
| Internet Required | Yes | **No** |
| Latency | 100ms – seconds | **< 30ms** |
| Privacy | Data sent to server | **Data stays on device** |
| Offline Support | No | **Yes** |
| Infrastructure Cost | High | **None** |

---

## Team

| Name | Student ID | Role |
|---|---|---|
| Ahmad Hamza | 1210381 | Research & Literature Review |
| Tala Khateeb | 1222091 | Technical Architecture Analysis |
| Laith Amro | 1230018 | Prototype Implementation |
| Mohammad Aljamal | 1220378 | Documentation & Presentation |

---

## Course

**COMP4310 — Mobile Software Development**  
Faculty of Engineering and Technology, Computer Science Department  
Birzeit University — June 2026
