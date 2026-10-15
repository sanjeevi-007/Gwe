# GWEN BLE Binary Protocol Specification

This document details the binary Bluetooth Low Energy (BLE) communication protocol between the GWEN ESP32 hardware device (Puck) and the companion Android Flutter app.

---

## 1. Service and Characteristic UUIDs

The GWEN device advertises a single primary GATT service using standard 128-bit custom UUIDs (based on Nordic UART-style base UUIDs):

| Name | UUID | Type | Properties | Description |
| :--- | :--- | :--- | :--- | :--- |
| **GWEN Service** | `6E400001-B5A3-F393-E0A9-E50E24DCCA9E` | Primary Service | — | Root service container for all GWEN characteristics |
| **Pulse Characteristic** | `6E400002-B5A3-F393-E0A9-E50E24DCCA9E` | Characteristic | Notify | Emits pulse measurements (MAX30102) |
| **Motion Characteristic** | `6E400003-B5A3-F393-E0A9-E50E24DCCA9E` | Characteristic | Notify | Emits raw 6-DoF IMU & intensity data (MPU6050) |
| **GPS Characteristic** | `6E400004-B5A3-F393-E0A9-E50E24DCCA9E` | Characteristic | Notify | Emits GPS navigation & fix data (NEO-6M) |
| **AI Result Characteristic** | `6E400005-B5A3-F393-E0A9-E50E24DCCA9E` | Characteristic | Notify | Emits on-device motion classification |
| **Device Status Characteristic** | `6E400006-B5A3-F393-E0A9-E50E24DCCA9E` | Characteristic | Notify | Emits system health, uptime, battery & diagnostics |
| **Time Sync Characteristic** | `6E400007-B5A3-F393-E0A9-E50E24DCCA9E` | Characteristic | Write | Host phone writes current UTC epoch seconds |
| **Config Characteristic** | `6E400008-B5A3-F393-E0A9-E50E24DCCA9E` | Characteristic | Read, Write | Read or configure notification interval & logging |

---

## 2. Endianness and Memory Alignment

- **Endianness:** All multi-byte integer fields (`uint16_t`, `int16_t`, `uint32_t`, `int32_t`) are encoded in **Little-Endian** byte order (least significant byte first).
- **Alignment:** C/C++ firmware structures must be packed using byte alignment (`#pragma pack(push, 1)`) to ensure zero compiler padding between struct members.
- **Floating Point:** No floating point IEEE-754 numbers are transmitted over BLE. Physical measurements requiring fractional precision (latitude, longitude, HDOP) are transmitted as scaled fixed-point integers.

---

## 3. Common Packet Header (9 Bytes)

Every notification payload emitted by the Puck starts with a mandatory 9-byte header:

```text
 0      1      2      3      4      5      6      7      8
+------+------+------+------+------+------+------+------+------+
| ver  | type |  seq (LE)   |       t_ms (LE)       |flags |
+------+------+------+------+------+------+------+------+------+
```

| Byte Offset | Field | Type | Description |
| :--- | :--- | :--- | :--- |
| **0** | `ver` | `uint8_t` | Protocol version. Current version = `0x01`. |
| **1** | `type` | `uint8_t` | Packet Type Identifier: <br>• `0x01` = Pulse <br>• `0x02` = Motion <br>• `0x03` = GPS <br>• `0x04` = AI Result <br>• `0x05` = Device Status |
| **2..3** | `seq` | `uint16_t` | Monotonically incrementing sequence number (per packet type), rolls over at 65535. Used for detecting dropped packets and duplicates. |
| **4..7** | `t_ms` | `uint32_t` | Device uptime timestamp in milliseconds at reading capture (`esp_timer_get_time() / 1000`). |
| **8** | `flags` | `uint8_t` | Status bitmask: <br>• **Bit 0**: `valid` (`1` = valid reading, `0` = invalid/discard) <br>• **Bit 1**: `stale` (`1` = cached/retransmitted old value, `0` = fresh) <br>• **Bit 2**: `sensor_error` (`1` = hardware error on I2C/UART bus) <br>• **Bits 3..7**: Reserved (set to 0) |

---

## 4. Payload Specifications

### 4.1 Type 0x01 — Pulse Packet
- **Payload Size:** 5 bytes
- **Total Packet Size:** 14 bytes (9 bytes header + 5 bytes payload)
- **Sensor:** MAX30102 via I2C

```text
Header (9B) + [bpm: 2B (LE)][spo2: 1B][quality: 1B][state: 1B]
```

| Payload Offset | Field | Type | Description |
| :--- | :--- | :--- | :--- |
| **0..1** | `bpm` | `uint16_t` | Heart rate in beats per minute. Special value: `0xFFFF` indicates no reading, no finger detected, or invalid reading. |
| **2** | `spo2` | `uint8_t` | Oxygen saturation. In Milestone 1–10 (v1), SpO2 is permanently disabled and transmits `0xFF` (off). |
| **3** | `quality` | `uint8_t` | Signal quality metric (`0`..`100`%). |
| **4** | `state` | `uint8_t` | Sensor state enum: <br>• `0` = `measuring` (acquiring signal) <br>• `1` = `valid` (stable pulse reading) <br>• `2` = `poorSignal` (motion artifact or low perfusion) <br>• `3` = `noFinger` (no object on sensor) <br>• `4` = `sensorError` (I2C communication failure) |

---

### 4.2 Type 0x02 — Motion Packet
- **Payload Size:** 14 bytes
- **Total Packet Size:** 23 bytes (9 bytes header + 14 bytes payload)
- **Sensor:** MPU6050 via I2C (sampled at 50 Hz, nominal notification at 1–5 Hz)

```text
Header (9B) + [ax: 2B][ay: 2B][az: 2B][gx: 2B][gy: 2B][gz: 2B][intensity: 1B][est_class: 1B]
```

| Payload Offset | Field | Type | Scaling / Unit | Description |
| :--- | :--- | :--- | :--- | :--- |
| **0..1** | `ax` | `int16_t` | `mg` (milli-g, $1g = 1000$) | Accelerometer X-axis |
| **2..3** | `ay` | `int16_t` | `mg` (milli-g, $1g = 1000$) | Accelerometer Y-axis |
| **4..5** | `az` | `int16_t` | `mg` (milli-g, $1g = 1000$) | Accelerometer Z-axis |
| **6..7** | `gx` | `int16_t` | `deg/s * 10` ($1^\circ/\text{s} = 10$) | Gyroscope X-axis |
| **8..9** | `gy` | `int16_t` | `deg/s * 10` ($1^\circ/\text{s} = 10$) | Gyroscope Y-axis |
| **10..11** | `gz` | `int16_t` | `deg/s * 10` ($1^\circ/\text{s} = 10$) | Gyroscope Z-axis |
| **12** | `intensity` | `uint8_t` | `0`..`255` | Normalized movement energy |
| **13** | `est_class`| `uint8_t` | Enum | Quick heuristic state: <br>• `0` = `stationary` <br>• `1` = `walking` <br>• `2` = `vigorous` <br>• `3` = `uncertain` |

---

### 4.3 Type 0x03 — GPS Packet
- **Payload Size:** 16 bytes
- **Total Packet Size:** 25 bytes (9 bytes header + 16 bytes payload)
- **Sensor:** NEO-6M via Hardware UART

```text
Header (9B) + [fix: 1B][sats: 1B][lat: 4B][lon: 4B][hdop: 2B][utc: 4B][age_s: 2B]
```

| Payload Offset | Field | Type | Scaling / Unit | Description |
| :--- | :--- | :--- | :--- | :--- |
| **0** | `fix` | `uint8_t` | Enum | GPS Fix status: <br>• `0` = `searching` <br>• `1` = `fix` (valid 2D/3D fix) <br>• `2` = `weak` (poor satellite geometry) <br>• `3` = `noFix` <br>• `4` = `disconnected` (UART timeout) |
| **1** | `sats` | `uint8_t` | Count | Number of tracked satellites (`0`..`32`) |
| **2..5** | `lat` | `int32_t` | `degrees * 1e7` | Latitude. E.g. $13.0826802^\circ \to 130826802$. Set to `0` when fix is invalid. |
| **6..9** | `lon` | `int32_t` | `degrees * 1e7` | Longitude. E.g. $80.2707184^\circ \to 802707184$. Set to `0` when fix is invalid. |
| **10..11**| `hdop` | `uint16_t`| `HDOP * 10` | Horizontal Dilution of Precision ($1.2 \to 12$) |
| **12..15**| `utc` | `uint32_t`| Epoch seconds | UTC time reported by GPS satellites |
| **16..17**| `age_s`| `uint16_t`| Seconds | Age of GPS fix in seconds since last NMEA lock |

---

### 4.4 Type 0x04 — AI Result Packet
- **Payload Size:** 5 bytes
- **Total Packet Size:** 14 bytes (9 bytes header + 5 bytes payload)
- **Engine:** TensorFlow Lite for Microcontrollers on ESP32

```text
Header (9B) + [label: 1B][score: 1B][model_ver: 2B][source: 1B]
```

| Payload Offset | Field | Type | Description |
| :--- | :--- | :--- | :--- |
| **0** | `label` | `uint8_t` | Motion class: <br>• `0` = `stationary` <br>• `1` = `walkingLike` <br>• `2` = `vigorous` <br>• `3` = `uncertain` <br>• `255` = `unavailable` |
| **1** | `score` | `uint8_t` | Classification confidence: `0`..`100`%. Special value: `255` = none or invalid. |
| **2..3** | `model_ver` | `uint16_t` | Semantic version integer of the active quantized model. |
| **4** | `source` | `uint8_t` | Provenance of classification: <br>• `0` = `none` <br>• `1` = `ruleBased` (heuristic estimate, app displays *"Motion estimate (rule-based)"*) <br>• `2` = `trainedModel` (real TFLite inference result) |

---

### 4.5 Type 0x05 — Device Status Packet
- **Payload Size:** 9 bytes
- **Total Packet Size:** 18 bytes (9 bytes header + 9 bytes payload)

```text
Header (9B) + [fw_major: 1B][fw_minor: 1B][fw_patch: 1B][sensors: 1B][uptime_s: 4B][battery: 1B]
```

| Payload Offset | Field | Type | Description |
| :--- | :--- | :--- | :--- |
| **0** | `fw_major` | `uint8_t` | Firmware major version |
| **1** | `fw_minor` | `uint8_t` | Firmware minor version |
| **2** | `fw_patch` | `uint8_t` | Firmware patch version |
| **3** | `sensors` | `uint8_t` | Bitmask of operational hardware components: <br>• **Bit 0**: `MAX30102` pulse sensor OK <br>• **Bit 1**: `MPU6050` IMU sensor OK <br>• **Bit 2**: `GPS` NEO-6M receiver OK <br>• **Bit 3**: `TFT` display controller OK <br>• **Bit 4**: `Model` neural network loaded in memory <br>• **Bits 5..7**: Reserved (0) |
| **4..7** | `uptime_s` | `uint32_t` | System uptime in seconds since boot |
| **8** | `battery` | `uint8_t` | Remaining battery percentage: `0`..`100`%. Special value: `255` = unknown / power supply |

---

## 5. Writable Characteristics

### 5.1 Time Sync Characteristic (`0x0007`)
- **Properties:** Write without response or Write
- **Payload Size:** 4 bytes
- **Payload Layout:** `[epoch: 4 bytes (uint32_t, little-endian)]`
- **Description:** Upon establishing a BLE link, the companion app retrieves the current Unix UTC epoch timestamp (in seconds) and writes it to this characteristic. The ESP32 sets its internal real-time clock (`settimeofday`) to synchronize logged events.

### 5.2 Config Characteristic (`0x0008`)
- **Properties:** Read, Write
- **Payload Size:** 3 bytes
- **Payload Layout:** `[notify_interval_ms: 2 bytes (uint16_t, LE)][location_logging: 1 byte (uint8_t)]`

| Offset | Field | Type | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| **0..1** | `notify_interval_ms` | `uint16_t` | `1000` | Notification interval in milliseconds (`200`..`10000`). |
| **2** | `location_logging` | `uint8_t` | `0` | Logging flag: `0` = off, `1` = log raw coordinates to internal SPIFFS. |

---

## 6. Freshness Rules & Honest Display Contract

1. **Pulse, Motion, AI:** A reading older than **5 seconds** is flagged as **Stale**.
2. **GPS:** A reading older than **30 seconds** is flagged as **Stale**.
3. **Honest Null Contract:** If a sensor is disconnected, searching, or invalid, fields (`bpm`, `lat`, `lon`, `battery`, `score`) are treated as **NULL** on the client, never as `0`.
4. **No Medical Claims:** Pulse and motion metrics are wellness metrics only. No diagnostic or emergency claims are ever derived from BLE payload data.
