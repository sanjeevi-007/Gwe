# GWEN — Offline Pulse, Motion & GPS Monitor

GWEN is an offline-first health monitor. The Puck (ESP32) reads pulse (MAX30102), motion (MPU6050) and GPS (NEO-6M), runs a small on-device AI motion classifier, and sends data over BLE to an Android Flutter app. Everything works offline. No cloud, no accounts, no internet required.

## Hard Rules

- No cloud/accounts/login/internet.
- AI runs on ESP32.
- Never show fake data.
- Not a medical device.
- No diagnosis, no SOS, no fall detection.
- SpO2 is OFF in v1.
- GPS stays on device.

## How to Run

### App
```bash
cd app
flutter run
```

### Firmware
```bash
cd firmware
pio run -t upload
```

### ML
```bash
cd ml
python train.py
```

## Repo Structure

```text
gwen/
├── app/
│   └── lib/
│       ├── core/
│       ├── models/
│       ├── ble/
│       ├── data/
│       ├── state/
│       ├── features/
│       │   ├── onboarding/
│       │   ├── home/
│       │   ├── pulse/
│       │   ├── motion/
│       │   ├── location/
│       │   ├── ai_insights/
│       │   ├── history/
│       │   └── settings/
│       └── widgets/
├── firmware/
│   ├── include/
│   └── src/
├── ml/
│   └── datasets/
├── docs/
└── .github/
    └── workflows/
```

## License

This project is licensed under the [MIT License](LICENSE).
