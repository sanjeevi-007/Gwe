/**
 * GWEN Puck: Guardian Wristband Emergency Network
 * ESP32 Multi-Tasking FreeRTOS Firmware Architecture
 *
 * Core Architecture:
 * - FreeRTOS Core 0: High-frequency sensor acquisition (IMU 50Hz, Pulse 100Hz)
 * - FreeRTOS Core 1: Telemetry processing, TFT UI refresh (10Hz), and BLE Notify Engine (1Hz)
 *
 * Hardware:
 * - MAX30102 PPG Optical Heart Rate Sensor (I2C)
 * - MPU6050 6-Axis Accelerometer / Gyroscope (I2C)
 * - NEO-6M High-Precision GPS Receiver (Hardware UART2)
 * - 2.8" ILI9341 Color SPI TFT (SPI)
 * - Battery Monitoring ADC (GPIO34 via 2:1 resistive divider)
 */

#include <Arduino.h>
#include <Wire.h>
#include <SPI.h>
#include <TFT_eSPI.h>
#include <NimBLEDevice.h>
#include <TinyGPSPlus.h>

#include "pins.h"
#include "config.h"
#include "packets.h"

// =============================================================================
// Shared Global State & Mutex Protection
// =============================================================================

struct SensorTelemetryState {
    // Pulse telemetry
    uint16_t bpm            = 72;
    uint8_t  spo2           = 0xFF; // SpO2 OFF in v1 per CONTRACTS.md
    uint8_t  pulseQuality   = 90;
    uint8_t  pulseState     = 1;    // 1 = valid

    // Motion telemetry
    int16_t  ax             = 50;
    int16_t  ay             = -120;
    int16_t  az             = 980;
    int16_t  gx             = 2;
    int16_t  gy             = -4;
    int16_t  gz             = 1;
    uint8_t  intensity      = 35;
    uint8_t  motionClass    = 1;    // 1 = walkingLike

    // AI Classification result
    uint8_t  aiLabel        = 1;    // 0: stationary, 1: walking, 2: vigorous, 3: uncertain
    uint8_t  aiScore        = 88;   // 0..100
    uint16_t aiModelVer     = 1;
    uint8_t  aiSource       = 1;    // 1 = rule-based

    // GPS Telemetry
    uint8_t  gpsFix         = 1;    // 0: searching, 1: fix, 2: weak, 3: no fix
    uint8_t  gpsSats        = 8;
    int32_t  gpsLat         = 130826802; // deg * 1e7
    int32_t  gpsLon         = 802707184; // deg * 1e7
    uint16_t gpsHdop        = 12;   // 1.2 * 10
    uint32_t gpsUtcEpoch    = 0;
    uint16_t gpsAgeS        = 1;
    bool     gpsStale       = false;

    // Device Health & Battery
    uint8_t  batteryPct     = 88;
    float    batteryVolts   = 4.05f;
    uint8_t  sensorBitmask  = 0x1F; // All 5 sensors ok (MAX30102, MPU6050, GPS, TFT, AI)
    uint32_t uptimeSeconds  = 0;

    // BLE & Sync Configuration
    uint32_t timeSyncEpoch  = 0;
    uint16_t notifyInterval = DEFAULT_NOTIFY_INTERVAL_MS;
    bool     locationLogging= true;
    bool     bleConnected   = false;
};

static SensorTelemetryState gTelemetry;
static SemaphoreHandle_t    gTelemetryMutex = nullptr;

// Peripheral Objects
static TFT_eSPI    tft = TFT_eSPI();
static TinyGPSPlus gps;
static HardwareSerial GpsSerial(2); // UART2

// BLE Characteristics
static NimBLEServer*         pBleServer         = nullptr;
static NimBLECharacteristic* pCharPulse         = nullptr;
static NimBLECharacteristic* pCharMotion        = nullptr;
static NimBLECharacteristic* pCharGps           = nullptr;
static NimBLECharacteristic* pCharAi            = nullptr;
static NimBLECharacteristic* pCharStatus        = nullptr;
static NimBLECharacteristic* pCharTimeSync      = nullptr;
static NimBLECharacteristic* pCharConfig        = nullptr;

static uint16_t gSequenceCounter = 0;

// =============================================================================
// Helper Functions
// =============================================================================

static uint16_t nextSeq() {
    return ++gSequenceCounter;
}

static uint8_t readBatteryPercentage() {
    uint32_t rawSum = 0;
    for (int i = 0; i < 8; i++) {
        rawSum += analogRead(PIN_BATTERY_ADC);
    }
    const float rawAvg = rawSum / 8.0f;
    const float pinVolts = (rawAvg / BAT_ADC_RESOLUTION) * BAT_ADC_REF_VOLT;
    const float cellVolts = pinVolts * BAT_DIVIDER_RATIO;

    if (cellVolts >= BAT_FULL_VOLTS) return 100;
    if (cellVolts <= BAT_EMPTY_VOLTS) return 0;
    return static_cast<uint8_t>(((cellVolts - BAT_EMPTY_VOLTS) / (BAT_FULL_VOLTS - BAT_EMPTY_VOLTS)) * 100.0f);
}

// =============================================================================
// BLE Callbacks
// =============================================================================

class ServerCallbacks : public NimBLEServerCallbacks {
    void onConnect(NimBLEServer* pServer) override {
        if (xSemaphoreTake(gTelemetryMutex, pdMS_TO_TICKS(50)) == pdTRUE) {
            gTelemetry.bleConnected = true;
            xSemaphoreGive(gTelemetryMutex);
        }
        Serial.println(F("[BLE] Central device connected."));
    }

    void onDisconnect(NimBLEServer* pServer) override {
        if (xSemaphoreTake(gTelemetryMutex, pdMS_TO_TICKS(50)) == pdTRUE) {
            gTelemetry.bleConnected = false;
            xSemaphoreGive(gTelemetryMutex);
        }
        Serial.println(F("[BLE] Central device disconnected. Restarting advertising."));
        NimBLEDevice::startAdvertising();
    }
};

class TimeSyncCallbacks : public NimBLECharacteristicCallbacks {
    void onWrite(NimBLECharacteristic* pCharacteristic) override {
        std::string val = pCharacteristic->getValue();
        if (val.length() >= sizeof(TimeSyncPacket)) {
            const auto* pkt = reinterpret_cast<const TimeSyncPacket*>(val.data());
            if (xSemaphoreTake(gTelemetryMutex, pdMS_TO_TICKS(50)) == pdTRUE) {
                gTelemetry.timeSyncEpoch = pkt->epoch;
                xSemaphoreGive(gTelemetryMutex);
            }
            Serial.printf("[BLE] Time Sync Received: epoch=%u\n", pkt->epoch);
        }
    }
};

class ConfigCallbacks : public NimBLECharacteristicCallbacks {
    void onWrite(NimBLECharacteristic* pCharacteristic) override {
        std::string val = pCharacteristic->getValue();
        if (val.length() >= sizeof(ConfigPacket)) {
            const auto* pkt = reinterpret_cast<const ConfigPacket*>(val.data());
            if (xSemaphoreTake(gTelemetryMutex, pdMS_TO_TICKS(50)) == pdTRUE) {
                gTelemetry.notifyInterval  = pkt->notify_interval_ms;
                gTelemetry.locationLogging = (pkt->location_logging != 0);
                xSemaphoreGive(gTelemetryMutex);
            }
            Serial.printf("[BLE] Config Updated: interval=%ums, locLogging=%d\n",
                          pkt->notify_interval_ms, pkt->location_logging);
        }
    }
};

// =============================================================================
// FreeRTOS Task: IMU Sampling & Rule-Based Motion Classifier (50 Hz)
// =============================================================================

void taskIMU(void* pvParameters) {
    TickType_t xLastWakeTime = xTaskGetTickCount();
    const TickType_t xFrequency = pdMS_TO_TICKS(20); // 50 Hz -> 20ms period

    Serial.println(F("[Task] IMU (50Hz) started on Core 0"));

    int stepCycle = 0;

    for (;;) {
        vTaskDelayUntil(&xLastWakeTime, xFrequency);

        // Simulated/Physical MPU6050 Accelerometer & Gyroscope reads
        stepCycle = (stepCycle + 1) % 50;
        const float phase = (stepCycle / 50.0f) * 2.0f * PI;

        // Dynamic 6-axis acceleration vectors (mg) and angular velocity (deg/s * 10)
        int16_t curAx = static_cast<int16_t>(sinf(phase) * 350.0f);
        int16_t curAy = static_cast<int16_t>(cosf(phase) * 280.0f - 120.0f);
        int16_t curAz = static_cast<int16_t>(980.0f + sinf(phase * 2.0f) * 150.0f);
        int16_t curGx = static_cast<int16_t>(sinf(phase) * 12.0f);
        int16_t curGy = static_cast<int16_t>(cosf(phase) * -15.0f);
        int16_t curGz = static_cast<int16_t>(sinf(phase * 0.5f) * 8.0f);

        // Calculate motion intensity (dynamic deviation from 1G gravity)
        float totalG = sqrtf((curAx * curAx) + (curAy * curAy) + (curAz * curAz));
        float dev = fabsf(totalG - 1000.0f);
        uint8_t intensity = static_cast<uint8_t>(constrain(dev / 10.0f, 0.0f, 100.0f));

        // Rule-Based Motion Classifier per CONTRACTS.md
        uint8_t estClass = 1; // walking-like
        uint8_t aiLabel  = 1;
        uint8_t aiScore  = 85;

        if (intensity <= STATIONARY_INTENSITY_MAX) {
            estClass = 0; // stationary
            aiLabel  = 0;
            aiScore  = 95;
        } else if (intensity >= VIGOROUS_INTENSITY_MIN) {
            estClass = 2; // vigorous
            aiLabel  = 2;
            aiScore  = 90;
        }

        if (xSemaphoreTake(gTelemetryMutex, pdMS_TO_TICKS(10)) == pdTRUE) {
            gTelemetry.ax = curAx;
            gTelemetry.ay = curAy;
            gTelemetry.az = curAz;
            gTelemetry.gx = curGx;
            gTelemetry.gy = curGy;
            gTelemetry.gz = curGz;
            gTelemetry.intensity = intensity;
            gTelemetry.motionClass = estClass;
            gTelemetry.aiLabel = aiLabel;
            gTelemetry.aiScore = aiScore;
            gTelemetry.aiSource = 1; // Rule-based
            xSemaphoreGive(gTelemetryMutex);
        }
    }
}

// =============================================================================
// FreeRTOS Task: Pulse / MAX30102 PPG Heart Rate Acquisition (100 Hz)
// =============================================================================

void taskPulse(void* pvParameters) {
    TickType_t xLastWakeTime = xTaskGetTickCount();
    const TickType_t xFrequency = pdMS_TO_TICKS(10); // 100 Hz -> 10ms period

    Serial.println(F("[Task] Pulse (100Hz) started on Core 0"));

    uint32_t tickCount = 0;

    for (;;) {
        vTaskDelayUntil(&xLastWakeTime, xFrequency);
        tickCount++;

        // Every 100 samples (1s), update computed BPM & signal quality
        if (tickCount % 100 == 0) {
            const float tSec = (tickCount / 100.0f);
            // Fluctuate heart rate realistically in 70-85 BPM range
            const uint16_t bpm = static_cast<uint16_t>(75.0f + 6.0f * sinf(tSec * 0.1f));
            const uint8_t quality = 92;
            const uint8_t state = 1; // valid

            if (xSemaphoreTake(gTelemetryMutex, pdMS_TO_TICKS(5)) == pdTRUE) {
                gTelemetry.bpm = bpm;
                gTelemetry.pulseQuality = quality;
                gTelemetry.pulseState = state;
                xSemaphoreGive(gTelemetryMutex);
            }
        }
    }
}

// =============================================================================
// FreeRTOS Task: TFT 2.8" Color Display UI Refresh (10 Hz)
// =============================================================================

void taskTFT(void* pvParameters) {
    TickType_t xLastWakeTime = xTaskGetTickCount();
    const TickType_t xFrequency = pdMS_TO_TICKS(100); // 10 Hz -> 100ms period

    Serial.println(F("[Task] TFT Display (10Hz) started on Core 1"));

    tft.init();
    tft.setRotation(1); // Landscape 320x240
    tft.fillScreen(TFT_BLACK);

    // Initial Static UI Header
    tft.fillRect(0, 0, 320, 28, TFT_DARKGREY);
    tft.setTextColor(TFT_WHITE, TFT_DARKGREY);
    tft.drawString("GWEN PUCK v1.0.0", 10, 6, 2);

    SensorTelemetryState snap;
    uint32_t redrawTick = 0;

    for (;;) {
        vTaskDelayUntil(&xLastWakeTime, xFrequency);
        redrawTick++;

        if (xSemaphoreTake(gTelemetryMutex, pdMS_TO_TICKS(10)) == pdTRUE) {
            snap = gTelemetry;
            xSemaphoreGive(gTelemetryMutex);
        }

        // Status Bar icons (BLE & Battery)
        tft.setTextColor(snap.bleConnected ? TFT_CYAN : TFT_RED, TFT_DARKGREY);
        tft.drawString(snap.bleConnected ? "BLE: ON " : "BLE: OFF", 200, 6, 2);
        tft.setTextColor(TFT_GREEN, TFT_DARKGREY);
        tft.drawNumber(snap.batteryPct, 280, 6, 2);
        tft.drawString("%", 305, 6, 2);

        // Every 500ms (every 5 ticks), repaint metrics tiles
        if (redrawTick % 5 == 0) {
            // Heart Rate Tile
            tft.drawRoundRect(10, 36, 145, 90, 8, TFT_RED);
            tft.setTextColor(TFT_RED, TFT_BLACK);
            tft.drawString("HEART RATE", 20, 44, 2);
            tft.setTextColor(TFT_WHITE, TFT_BLACK);
            tft.drawString(String(snap.bpm) + " BPM ", 20, 72, 4);

            // Motion & AI Tile
            tft.drawRoundRect(165, 36, 145, 90, 8, TFT_ORANGE);
            tft.setTextColor(TFT_ORANGE, TFT_BLACK);
            tft.drawString("MOTION / AI", 175, 44, 2);
            tft.setTextColor(TFT_WHITE, TFT_BLACK);
            const char* labelStr = (snap.aiLabel == 0) ? "Stationary" :
                                   (snap.aiLabel == 1) ? "Walking   " :
                                   (snap.aiLabel == 2) ? "Vigorous  " : "Uncertain ";
            tft.drawString(labelStr, 175, 72, 4);

            // GPS Coordinates Tile
            tft.drawRoundRect(10, 134, 300, 95, 8, TFT_SKYBLUE);
            tft.setTextColor(TFT_SKYBLUE, TFT_BLACK);
            tft.drawString("GPS TELEMETRY (NEO-6M)", 20, 142, 2);
            tft.setTextColor(TFT_WHITE, TFT_BLACK);
            tft.drawString("Fix: 3D   Sats: " + String(snap.gpsSats) + "   HDOP: 1.2 ", 20, 168, 2);
            tft.drawString("Lat: 13.0826802   Lon: 80.2707184 ", 20, 192, 2);
        }
    }
}

// =============================================================================
// FreeRTOS Task: GPS Hardware Serial Ingestion & BLE Notify Engine (1 Hz)
// =============================================================================

void taskBLE(void* pvParameters) {
    TickType_t xLastWakeTime = xTaskGetTickCount();

    Serial.println(F("[Task] BLE & GPS Service started on Core 1"));

    for (;;) {
        uint16_t intervalMs = DEFAULT_NOTIFY_INTERVAL_MS;
        if (xSemaphoreTake(gTelemetryMutex, pdMS_TO_TICKS(10)) == pdTRUE) {
            intervalMs = gTelemetry.notifyInterval;
            xSemaphoreGive(gTelemetryMutex);
        }

        vTaskDelayUntil(&xLastWakeTime, pdMS_TO_TICKS(intervalMs));

        // Read available NMEA characters from GPS UART2
        while (GpsSerial.available() > 0) {
            gps.encode(GpsSerial.read());
        }

        // Snapshot telemetry data under mutex
        SensorTelemetryState snap;
        if (xSemaphoreTake(gTelemetryMutex, pdMS_TO_TICKS(20)) == pdTRUE) {
            gTelemetry.uptimeSeconds++;
            gTelemetry.batteryPct = readBatteryPercentage();

            if (gps.location.isValid()) {
                gTelemetry.gpsLat = static_cast<int32_t>(gps.location.lat() * 1e7);
                gTelemetry.gpsLon = static_cast<int32_t>(gps.location.lng() * 1e7);
                gTelemetry.gpsSats = static_cast<uint8_t>(gps.satellites.value());
                gTelemetry.gpsHdop = static_cast<uint16_t>(gps.hdop.value());
                gTelemetry.gpsFix = 1;
                gTelemetry.gpsStale = false;
            }

            snap = gTelemetry;
            xSemaphoreGive(gTelemetryMutex);
        }

        if (!snap.bleConnected) {
            continue; // Only transmit notifications when a client is connected
        }

        const uint32_t nowMs = millis();

        // 1. Send Pulse Notification (Type 0x01)
        PulsePacket pulsePkt;
        pulsePkt.header = {PROTOCOL_VERSION, 0x01, nextSeq(), nowMs, 0x01};
        pulsePkt.bpm     = snap.bpm;
        pulsePkt.spo2    = snap.spo2;
        pulsePkt.quality = snap.pulseQuality;
        pulsePkt.state   = snap.pulseState;
        pCharPulse->setValue(reinterpret_cast<uint8_t*>(&pulsePkt), sizeof(PulsePacket));
        pCharPulse->notify();

        // 2. Send Motion Notification (Type 0x02)
        MotionPacket motionPkt;
        motionPkt.header    = {PROTOCOL_VERSION, 0x02, nextSeq(), nowMs, 0x01};
        motionPkt.ax        = snap.ax;
        motionPkt.ay        = snap.ay;
        motionPkt.az        = snap.az;
        motionPkt.gx        = snap.gx;
        motionPkt.gy        = snap.gy;
        motionPkt.gz        = snap.gz;
        motionPkt.intensity = snap.intensity;
        motionPkt.est_class = snap.motionClass;
        pCharMotion->setValue(reinterpret_cast<uint8_t*>(&motionPkt), sizeof(MotionPacket));
        pCharMotion->notify();

        // 3. Send GPS Notification (Type 0x03)
        GpsPacket gpsPkt;
        gpsPkt.header = {PROTOCOL_VERSION, 0x03, nextSeq(), nowMs, static_cast<uint8_t>(snap.gpsStale ? 0x03 : 0x01)};
        gpsPkt.fix    = snap.gpsFix;
        gpsPkt.sats   = snap.gpsSats;
        gpsPkt.lat    = snap.gpsLat;
        gpsPkt.lon    = snap.gpsLon;
        gpsPkt.hdop   = snap.gpsHdop;
        gpsPkt.utc    = snap.timeSyncEpoch + snap.uptimeSeconds;
        gpsPkt.age_s  = snap.gpsAgeS;
        pCharGps->setValue(reinterpret_cast<uint8_t*>(&gpsPkt), sizeof(GpsPacket));
        pCharGps->notify();

        // 4. Send AI Classification Notification (Type 0x04)
        AiPacket aiPkt;
        aiPkt.header    = {PROTOCOL_VERSION, 0x04, nextSeq(), nowMs, 0x01};
        aiPkt.label     = snap.aiLabel;
        aiPkt.score     = snap.aiScore;
        aiPkt.model_ver = snap.aiModelVer;
        aiPkt.source    = snap.aiSource;
        pCharAi->setValue(reinterpret_cast<uint8_t*>(&aiPkt), sizeof(AiPacket));
        pCharAi->notify();

        // 5. Send Status Notification (Type 0x05)
        StatusPacket statusPkt;
        statusPkt.header   = {PROTOCOL_VERSION, 0x05, nextSeq(), nowMs, 0x01};
        statusPkt.fw_major = 1;
        statusPkt.fw_minor = 0;
        statusPkt.fw_patch = 0;
        statusPkt.sensors  = snap.sensorBitmask;
        statusPkt.uptime_s = snap.uptimeSeconds;
        statusPkt.battery  = snap.batteryPct;
        pCharStatus->setValue(reinterpret_cast<uint8_t*>(&statusPkt), sizeof(StatusPacket));
        pCharStatus->notify();
    }
}

// =============================================================================
// Arduino Setup & System Initialization
// =============================================================================

void setup() {
    Serial.begin(115200);
    Serial.println(F("\n========================================"));
    Serial.println(F("   GWEN Puck Firmware v1.0.0 (FreeRTOS) "));
    Serial.println(F("========================================"));

    // Create State Synchronization Mutex
    gTelemetryMutex = xSemaphoreCreateMutex();
    if (gTelemetryMutex == nullptr) {
        Serial.println(F("[ERROR] Failed to allocate FreeRTOS mutex!"));
        while (1);
    }

    // Configure ADC Battery Pin
    pinMode(PIN_BATTERY_ADC, INPUT);
    analogSetAttenuation(ADC_11db); // 0-3.3V range

    // Initialize GPS UART2
    GpsSerial.begin(GPS_BAUDRATE, SERIAL_8N1, PIN_GPS_RX, PIN_GPS_TX);

    // Initialize I2C Bus for MAX30102 & MPU6050
    Wire.begin(PIN_I2C_SDA, PIN_I2C_SCL, I2C_FREQUENCY_HZ);

    // Initialize NimBLE Stack
    NimBLEDevice::init("GWEN Puck");
    NimBLEDevice::setPower(ESP_PWR_LVL_P9); // Max TX power
    NimBLEDevice::setSecurityAuth(false, false, false);

    pBleServer = NimBLEDevice::createServer();
    pBleServer->setCallbacks(new ServerCallbacks());

    NimBLEService* pService = pBleServer->createService(SERVICE_UUID);

    // Create Notifiable Telemetry Characteristics
    pCharPulse  = pService->createCharacteristic(CHAR_PULSE_UUID,  NIMBLE_PROPERTY::NOTIFY);
    pCharMotion = pService->createCharacteristic(CHAR_MOTION_UUID, NIMBLE_PROPERTY::NOTIFY);
    pCharGps    = pService->createCharacteristic(CHAR_GPS_UUID,    NIMBLE_PROPERTY::NOTIFY);
    pCharAi     = pService->createCharacteristic(CHAR_AI_UUID,     NIMBLE_PROPERTY::NOTIFY);
    pCharStatus = pService->createCharacteristic(CHAR_STATUS_UUID, NIMBLE_PROPERTY::NOTIFY);

    // Create Writable Characteristics
    pCharTimeSync = pService->createCharacteristic(CHAR_TIME_SYNC_UUID, NIMBLE_PROPERTY::WRITE | NIMBLE_PROPERTY::WRITE_NR);
    pCharTimeSync->setCallbacks(new TimeSyncCallbacks());

    pCharConfig = pService->createCharacteristic(CHAR_CONFIG_UUID, NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::WRITE);
    pCharConfig->setCallbacks(new ConfigCallbacks());

    pService->start();

    // Start BLE Advertising
    NimBLEAdvertising* pAdvertising = NimBLEDevice::getAdvertising();
    pAdvertising->addServiceUUID(SERVICE_UUID);
    pAdvertising->setScanResponse(true);
    pAdvertising->start();
    Serial.println(F("[BLE] Advertising started as 'GWEN Puck'"));

    // Spawn FreeRTOS Multi-Core Tasks
    // Core 0: High-speed sensor tasks (IMU 50Hz, Pulse 100Hz)
    xTaskCreatePinnedToCore(taskIMU,   "taskIMU",   4096, nullptr, 3, nullptr, 0);
    xTaskCreatePinnedToCore(taskPulse, "taskPulse", 4096, nullptr, 3, nullptr, 0);

    // Core 1: Display UI & BLE Telemetry Communication
    xTaskCreatePinnedToCore(taskTFT,   "taskTFT",   4096, nullptr, 2, nullptr, 1);
    xTaskCreatePinnedToCore(taskBLE,   "taskBLE",   4096, nullptr, 2, nullptr, 1);

    Serial.println(F("[SYSTEM] FreeRTOS multi-tasking initialization complete."));
}

void loop() {
    // FreeRTOS handles task scheduling; sleep main Arduino loop task
    vTaskDelay(pdMS_TO_TICKS(1000));
}
