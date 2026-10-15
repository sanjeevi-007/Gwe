# GWEN — Guardian Wristband Emergency Network

**100% Offline-First Wearable Telemetry & Health Monitoring Platform**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Release](https://img.shields.io/badge/Release-v1.0.0-emerald.svg)](https://github.com/sanjeevi-007/Gwe/releases/tag/v1.0.0)
[![Offline-First](https://img.shields.io/badge/Data-100%25%20Local%20%26%20Private-darkgreen.svg)](#privacy--offline-guarantee)
[![Architecture](https://img.shields.io/badge/Firmware-FreeRTOS%20%2B%20TFLite%20Micro-orange.svg)](#system-architecture)
[![App](https://img.shields.io/badge/App-Flutter%20%2B%20Drift%20SQLite-blueviolet.svg)](#how-to-run)

GWEN is a privacy-preserving, zero-cloud personal monitoring system designed for continuous health telemetry and on-device machine learning inference. The system couples an **ESP32 wearable Puck** with an **offline-first Android companion app**.

The Puck gathers real-time biometric and environmental telemetry (pulse, 6-axis inertial motion, GPS coordinates, and battery health), executes a multi-layer neural network directly on microcontroller silicon, and streams compressed binary packets over Bluetooth Low Energy (BLE) to the phone for local SQLite indexing and charting.

---

## Important Non-Medical Device Notice

> [!WARNING]
> **GWEN IS NOT A MEDICAL DEVICE.**
>
> GWEN is designed strictly for informational, educational, and sports fitness monitoring purposes.
> - **No Diagnostic Claims**: GWEN does not diagnose, treat, cure, mitigate, or prevent any illness, disease, or medical condition.
> - **No Emergency Monitoring**: GWEN does not provide automatic fall detection, emergency SOS alerts, or dispatch medical aid.
> - **Consult Healthcare Professionals**: Never disregard professional medical advice or delay seeking treatment based on telemetry displayed by this application.
> - **In Case of Emergency**: Call your local emergency services (e.g. 911, 112) immediately.

---

## System Architecture

```text
+-----------------------------------------------------------------------------------------+
|                                    GWEN PUCK (ESP32)                                    |
|                                                                                         |
|  +--------------------+   +--------------------+   +---------------------------------+  |
|  | MAX30102 (PPG I2C) |   |  MPU6050 (IMU I2C) |   |    NEO-6M GPS (UART2 9600)      |  |
|  |   100Hz Sampling   |   |   50Hz Sampling    |   |     1Hz Coordinate Fix          |  |
|  +---------+----------+   +---------+----------+   +----------------+----------------+  |
|            |                        |                               |                   |
|            |  +---------------------+                               |                   |
|            |  |                                                     |                   |
|            v  v                                                     v                   |
|  +-------------------------------------+           +---------------------------------+  |
|  | FreeRTOS Core 0: Acquisition Tasks  |           | FreeRTOS Core 1: System Service |  |
|  | - 100Hz Heart Rate / State Logic    |           | - 10Hz ILI9341 2.8" SPI TFT UI  |  |
|  | - 50Hz Statistical Window (100 pts) |           | - ADC Battery Voltage Monitor   |  |
|  | - On-Device TFLite Micro Inference  |           | - Thread-Safe Mutex Telemetry   |  |
|  +------------------+------------------+           +----------------+----------------+  |
|                     |                                               |                   |
|                     +-----------------------+-----------------------+                   |
|                                             |                                           |
|                                             v                                           |
|                              +-----------------------------+                            |
|                              |    NimBLE Server Engine     |                            |
|                              +--------------+--------------+                            |
+---------------------------------------------|-------------------------------------------+
                                              |
                                              |  Binary BLE Notifications (Little-Endian)
                                              |  [0x01 Pulse | 0x02 Motion | 0x03 GPS
                                              |   0x04 AI Classification | 0x05 Status]
                                              v
+-----------------------------------------------------------------------------------------+
|                                FLUTTER ANDROID APPLICATION                              |
|                                                                                         |
|  +-----------------------------------------------------------------------------------+  |
|  | BLE Ingestion Layer (flutter_blue_plus / MockBleService SIM)                      |  |
|  | - Zero-allocation binary parser (`PacketParser`)                                  |  |
|  | - Out-of-order sequence detection & gap tracking (`SequenceTracker`)             |  |
|  | - Phone GPS Bridge for indoor simulation (`PhoneGpsBridge`)                       |  |
|  +------------------------------------------+----------------------------------------+  |
|                                             |                                           |
|                                             v                                           |
|  +-----------------------------------------------------------------------------------+  |
|  | State & Persistence Engine (Riverpod 2.0 + Drift SQLite)                          |  |
|  | - Local relational schema (`pulse`, `motion`, `gps`, `ai_results`, `devices`)     |  |
|  | - Configurable history retention purge (24h, 7d, 30d, Keep Forever)               |  |
|  | - Offline CSV & JSON export via system Share Sheet (`share_plus`)                 |  |
|  +------------------------------------------+----------------------------------------+  |
|                                             |                                           |
|                                             v                                           |
|  +-----------------------------------------------------------------------------------+  |
|  | Material 3 UI Presentation Shell (5 Responsive Navigation Tabs)                   |  |
|  | - Home Dashboard: Live cards, age freshness indicators, quick-inspect modal      |  |
|  | - Pulse Screen: Real-time BPM display, quality index, 15m/1h/24h gap charts      |  |
|  | - Motion Screen: Friendly status, Raw IMU 6-axis vectors toggle, AI confidence    |  |
|  | - Location Screen: 6-State GPS visualizer, satellite counts, HDOP, Map tile      |  |
|  | - History & Settings: Aggregated metrics, data retention, DB purge, Onboarding   |  |
|  +-----------------------------------------------------------------------------------+  |
+-----------------------------------------------------------------------------------------+
```

---

## Key Features

- **100% Offline & Zero Cloud**: No user accounts, logins, telemetry tracking, or external network requests. All data stays entirely on your physical device.
- **On-Device Neural Motion Classification**: Scikit-Learn trained Multi-Layer Perceptron (MLP) deployed directly onto the ESP32 via FreeRTOS C++ inference (`Stationary`, `Walking-like`, `Vigorous`, and fallback `Uncertain`).
- **Real-Time Pulse & Signal Quality**: Heart rate monitoring with PPG signal quality indicators (Valid, Poor Signal, No Finger Contact, Sensor Error).
- **6-State Comprehensive GPS Engine**: Handles Searching, Valid 3D Fix, Weak Signal, Stale (>30s), No Fix, and GPS Disconnected states with satellite telemetry and HDOP precision ratings.
- **Phone GPS Bridge**: Integrated phone GPS bridge to feed real or simulated smartphone location directly into Puck telemetry channels.
- **Offline Data Portability**: Complete manual export to CSV (`pulse_readings.csv`, `motion_readings.csv`, `gps_readings.csv`) and JSON (`gwen_export.json`) via Android Share Sheet.
- **Privacy & History Retention**: Automated database pruning options (24 Hours, 7 Days, 30 Days, or Forever) with a one-tap Red Alert local database purge button.
- **Aesthetic Dark Theme UI**: High-contrast, accessibility-first theme engineered for outdoor visibility and OLED battery efficiency.

---

## How to Run

### 1. Flutter Mobile Application (Android / Simulator)
The app includes a 100% Software-in-the-Loop simulator (`MockPuck`) and can run without physical hardware:

```bash
cd app

# Check dependencies & run static analysis
flutter analyze

# Execute all automated unit and widget tests
flutter test

# Run app on connected Android phone or emulator
flutter run
```

### 2. PlatformIO ESP32 Firmware
Compile and flash the firmware onto an ESP32 microcontroller:

```bash
cd firmware

# Compile C++ FreeRTOS firmware with NimBLE and TFT_eSPI
pio run

# Flash to connected ESP32 via USB UART
pio run -t upload

# Open serial monitor (115200 baud)
pio device monitor -b 115200
```

### 3. Machine Learning Training Pipeline
Retrain the neural motion classifier and regenerate embedded C++ model quantization arrays:

```bash
cd ml

# Train MLP classifier, evaluate test accuracy, and export model_data.h
python train.py
```

---

## Hardware Pinout Reference

For complete hardware assembly schematics, resistor divider circuits, and 3.3V logic protection guidance, see [Hardware Wiring Documentation](docs/wiring.md).

| Peripheral | Bus | Pins | Notes |
| :--- | :--- | :--- | :--- |
| **MAX30102 PPG** | I2C | SDA: GPIO 21, SCL: GPIO 22 | 3.3V power, 400kHz Fast I2C |
| **MPU6050 IMU** | I2C | SDA: GPIO 21, SCL: GPIO 22 | Address `0x68`, 50Hz sampling |
| **NEO-6M GPS** | UART2 | RX: GPIO 16, TX: GPIO 17 | 9600 Baud, cross-connected |
| **ILI9341 2.8" TFT** | SPI | CS: 15, DC: 2, RST: 4, SCK: 18, MOSI: 23 | Hardware VSPI, 40MHz |
| **Battery Divider** | ADC | GPIO 34 (ADC1_CH6) | 100kΩ / 100kΩ 2:1 resistive divider |

---

## Repository Structure

```text
gwen/
├── app/                          # Flutter Android Application
│   ├── lib/
│   │   ├── ble/                  # BLE service, MockPuck, parser, GPS bridge
│   │   ├── core/                 # AppTheme, permission helper, constants
│   │   ├── data/                 # Drift SQLite database, repositories, export
│   │   ├── features/             # Feature UI screens (Home, Pulse, Motion, GPS, Settings)
│   │   ├── models/               # Domain telemetry data models & enums
│   │   ├── state/                # Riverpod reactive state providers
│   │   └── widgets/              # Reusable UI widgets, cards, charts, badges
│   └── test/                     # Comprehensive unit & widget test suite (80+ tests)
├── firmware/                     # Embedded ESP32 C++ PlatformIO Codebase
│   ├── include/                  # Pin maps, binary packet definitions, model_data.h
│   └── src/                      # FreeRTOS multi-core main.cpp, ai_inference.cpp
├── ml/                           # Python Machine Learning Pipeline
│   ├── datasets/                 # IMU training datasets
│   └── train.py                  # Synthetic generator, feature extractor, exporter
├── docs/                         # Project Documentation
│   ├── ble-protocol.md           # 9-byte header binary BLE specification
│   ├── wiring.md                 # Hardware assembly, pinouts & schematics
│   └── test-checklists.md        # Hardware, app & milestone QA checklists
├── CONTRACTS.md                  # System rules, data contracts & SQLite schema
└── LICENSE                       # MIT Open Source License
```

---

## License

This project is licensed under the [MIT License](LICENSE).
