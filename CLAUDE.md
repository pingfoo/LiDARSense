# CLAUDE.md

## Project Overview

LiDARSense is an iOS/iPadOS research app for LiDAR-based 3D spatial recognition and point cloud capture. Built with Swift/SwiftUI, ARKit, and SceneKit. Requires a real LiDAR-equipped iPhone or iPad (no simulator support).

## Tech Stack

- **Language:** Swift 5.0
- **UI Framework:** SwiftUI
- **Platform:** iOS/iPadOS 16.4+
- **Build Tool:** Xcode 12.0+ with Swift Package Manager
- **Dependencies:** ZIPFoundation v0.9.16 (ZIP archive creation)

## Project Structure

```
LiDARSense/
├── LiDARSense/                  # Main app source
│   ├── LiDARSenseApp.swift      # App entry point
│   ├── ContentView.swift        # Main UI, point cloud capture, PLY export
│   ├── ARSceneView.swift        # ARKit session and SceneKit rendering
│   └── Extensions.swift         # SCNGeometry mesh conversion extensions
├── LiDARSenseTests/             # Unit tests (XCTest)
├── LiDARSenseUITests/           # UI tests (XCTest)
└── LiDARSense.xcodeproj/       # Xcode project configuration
```

## Build & Run

Open `LiDARSense.xcodeproj` in Xcode and build to a real LiDAR-equipped device. This project cannot run on the iOS Simulator.

## Testing

Tests use Apple's XCTest framework. Run with `Cmd+U` in Xcode or via `xcodebuild test`.

```bash
xcodebuild test \
  -project LiDARSense.xcodeproj \
  -scheme LiDARSense \
  -destination 'platform=iOS,name=<device_name>'
```

Note: UI tests and some unit tests require a physical device with LiDAR.

## Key Concepts

- **PLY format:** Point cloud data is exported in PLY (Polygon File Format), a standard 3D data format
- **ARMeshGeometry:** LiDAR mesh data from ARKit, converted to SceneKit geometry via `Extensions.swift`
- **Capture workflow:** Take (start collecting) -> Stop (end + photo) -> Share (ZIP export via AirDrop, email, etc.)

## Code Conventions

- SwiftUI declarative patterns
- No linter or formatter configured; follow existing code style
- Japanese comments appear in some files (original authors at OPTiM Corp.)
