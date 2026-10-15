# GWEN: Solo Build Plan

**1 person, 11 sequential branches, merge to main after every milestone**

Repo: https://github.com/sanjeevi-007/Gwe

**Golden rule:** you are one person, so the order matters. Build the app first against a fake Puck (MockPuck) so you never wait for hardware. Everything is built against the fixed contracts below. Swap mocks for real hardware only in the milestones that say so.

## 0. SHARED FOUNDATION

### Product in one paragraph
GWEN is an offline-first pulse, motion and GPS monitor. The Puck is an ESP32 with a MAX30102 (pulse), MPU6050 (motion), NEO-6M (GPS) and a 2.8-inch TFT. It runs a small AI motion classifier on the ESP32 itself and sends data over BLE. The App is an Android Flutter app that receives the BLE data, shows live readings, saves history locally and shows charts.

### Hard rules
- No cloud, no accounts, no login, no internet. Everything works offline.
- The AI runs on the ESP32. The app only displays the result.
- Never show fake data. A missing, old or poor reading shows Unavailable, Signal poor, Stale or Unknown.
- Every reading has its own timestamp and a valid flag. Gaps are plotted as gaps, never as zero.
- Not a medical device: no diagnosis, no normal/abnormal labels, no fall detection, no SOS, no emergency claims.
- Excluded: ECG, SOS, LoRa, microphone, speaker, cloud AI, environmental sensors. SpO2 is OFF in v1.
- Until a trained model exists, label any rule-based motion result Motion estimate (rule-based), never AI.
- GPS coordinates are never uploaded. They stay on the Puck and phone unless the user exports them manually.
- The Puck keeps working when BLE disconnects or the app is closed.
- The ESP32 board model is UNKNOWN. All pins live in one file: firmware/include/pins.h.

### App database schema (Drift / SQLite)
devices (id, name, ble_id, firmware_version, first_connected_at)
pulse_readings (id, device_id FK, ts_device, ts_received, bpm nullable, quality, state, valid BOOLEAN)
motion_readings (id, device_id FK, ts_device, ts_received, ax, ay, az, gx, gy, gz, intensity, valid BOOLEAN)
gps_readings (id, device_id FK, ts_device, ts_received, fix_state, lat nullable, lon nullable, satellites, hdop nullable, valid BOOLEAN, stale BOOLEAN)
ai_results (id, device_id FK, ts_device, ts_received, label, score nullable, model_version, source)
connection_events (id, device_id FK, ts, event, reason nullable)
app_settings (key, value)

### BLE contract
All multi-byte values are little-endian. Use packed structs on the ESP32.

Header on every notification (9 bytes):
[ver u8][type u8][seq u16][t_ms u32][flags u8] then payload
flags: bit0 valid, bit1 stale, bit2 sensor_error

Type 0x01 Pulse: bpm u16 (0xFFFF=none), spo2 u8 (0xFF=off), quality u8 (0-100), state u8
Type 0x02 Motion: ax i16, ay i16, az i16 (mg), gx i16, gy i16, gz i16 (deg/s x10), intensity u8, est_class u8
Type 0x03 GPS: fix u8, sats u8, lat i32 (deg x1e-7), lon i32 (deg x1e-7), hdop u16 (x10), utc u32 (epoch s), age_s u16
Type 0x04 AI Result: label u8, score u8 (0-100, 255=none), model_ver u16, source u8
Type 0x05 Device Status: fw_major u8, fw_minor u8, fw_patch u8, sensors u8 (bitmask), uptime_s u32, battery u8 (255=unknown)

Enums:
pulse.state: 0 measuring, 1 valid, 2 poor signal, 3 no finger, 4 sensor error
gps.fix: 0 searching, 1 fix, 2 weak, 3 no fix, 4 gps disconnected
ai.label: 0 stationary, 1 walking-like, 2 vigorous, 3 uncertain, 255 unavailable
ai.source: 0 none, 1 rule-based, 2 trained model
sensors bit: 0 max30102, 1 mpu6050, 2 gps, 3 tft, 4 model loaded

Writable characteristics:
- Time Sync (write): epoch u32
- Config (read/write): notify_interval_ms u16, location_logging u8

### Definition of freshness
Every card shows its own age. A value older than 5 seconds (pulse, motion, AI) or 30 seconds (GPS) is marked Stale.
