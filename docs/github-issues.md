# GWEN: GitHub Issues for Milestones M0–M10

This file contains ready-to-paste issues to create on GitHub for tracking project milestones.

---

**M0: Repo Scaffold and CI**
Labels: milestone
- [ ] Repo is on GitHub
- [ ] CI workflow runs and is green
- [ ] CONTRACTS.md is committed
- [ ] README renders correctly
- [ ] Tag v0.0.0 created

---

**M1: Flutter App Core and Local Database**
Labels: milestone, app
- [ ] Flutter project created with Material 3
- [ ] Dependencies added: flutter_riverpod, drift, fl_chart, permission_handler, flutter_blue_plus, share_plus
- [ ] Light and dark themes configured
- [ ] Typed models: PulseReading, MotionReading, GpsReading, AiResult, DeviceStatus
- [ ] Drift database with all 7 tables
- [ ] Repositories with insert, latest, range-query, delete-all
- [ ] 5-tab bottom navigation shell (Home, Insights, Location, AI, Settings)
- [ ] StaleBadge and StatusCard widgets
- [ ] Unit tests pass for repositories
- [ ] flutter analyze clean
- [ ] Tag v0.1.0

---

**M2: BLE Protocol Spec, Parser and Packet Header**
Labels: milestone, app, firmware
- [ ] docs/ble-protocol.md with UUIDs, payloads, enums
- [ ] Dart packet_parser.dart handles all 5 types + errors
- [ ] C++ packets.h with packed structs and static_assert
- [ ] config.h with UUIDs
- [ ] Parser unit tests with hand-built byte arrays
- [ ] Sequence number tracker for dropped/duplicate detection
- [ ] Tag v0.2.0

---

**M3: MockPuck and Home Dashboard**
Labels: milestone, app
- [ ] MockPuck emits all packet types and cycles scenarios
- [ ] Debug menu to force scenarios
- [ ] BleService interface with Mock and Real stub
- [ ] Riverpod streams for connection state and readings
- [ ] Repository saves parsed readings to Drift
- [ ] Home tab with 5 cards (Pulse, Motion, GPS, AI, Device)
- [ ] Freshness rules applied per card
- [ ] Widget tests for each card state
- [ ] Tag v0.3.0

---

**M4: Detail Screens and History**
Labels: milestone, app
- [ ] Pulse screen with chart, range selector, gap handling
- [ ] Motion screen with friendly label + raw toggle
- [ ] Location screen with all 6 GPS states
- [ ] AI Insights screen with limitations section
- [ ] History tab with averages and missing-data periods
- [ ] Tag v0.4.0

---

**M5: Settings, Onboarding, Export and Permissions**
Labels: milestone, app
- [ ] Onboarding flow with disclaimer
- [ ] Permission handling (Android 12+ and 11-)
- [ ] Device scan and pick screen
- [ ] Settings screen with all options
- [ ] Mock/Real switch
- [ ] Delete-all-history
- [ ] Export CSV and JSON via share sheet
- [ ] test-checklists.md updated for Mock mode
- [ ] Tag v0.5.0

---

**M6: Firmware Bring-Up**
Labels: milestone, firmware, hardware
- [ ] platformio.ini configured for board
- [ ] pins.h with verified pin map
- [ ] TFT splash screen
- [ ] I2C scan finds 0x57 and 0x68
- [ ] GPS raw NMEA prints to serial
- [ ] docs/wiring.md created
- [ ] Tag v0.6.0

---

**M7: Firmware Sensors, Processing and TFT**
Labels: milestone, firmware, hardware
- [ ] MAX30102 pulse with quality and honest states
- [ ] MPU6050 at 50 Hz with intensity
- [ ] GPS receiver with all fix states
- [ ] Rule-based motion estimate
- [ ] TFT display with all cards
- [ ] FreeRTOS tasks running
- [ ] Tag v0.7.0

---

**M8: BLE Server and Real Link**
Labels: milestone, firmware, app, hardware
- [ ] NimBLE server advertising GWEN service
- [ ] All 5 notification types sent
- [ ] Time Sync and Config characteristics
- [ ] Pairing with bonding
- [ ] Verified with nRF Connect
- [ ] App real BleService connects and parses
- [ ] Reconnection with backoff
- [ ] Foreground service for background sync
- [ ] All disconnect scenarios tested
- [ ] Tag v0.8.0

---

**M9: ML Model**
Labels: milestone, firmware, ml
- [ ] Data logging mode over serial
- [ ] Python recording script
- [ ] train.py with session-based split
- [ ] export_tflite.py with int8 quantization
- [ ] TFLite Micro inference on ESP32
- [ ] Confidence gating with Uncertain fallback
- [ ] source=2 when trained model runs
- [ ] Tag v0.9.0

---

**M10: Power, Validation and Release**
Labels: milestone, firmware, app
- [ ] Battery voltage monitoring
- [ ] Power guidance in wiring.md
- [ ] All checklist items pass
- [ ] Error handling verified
- [ ] Release APK built
- [ ] Firmware tagged
- [ ] README updated with screenshots and limitations
- [ ] Tag v0.10.0
