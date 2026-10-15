#ifndef PINS_H
#define PINS_H

#include <stdint.h>

// =============================================================================
// GWEN ESP32 Hardware Pin Assignments
// =============================================================================
// Central hardware pin mapping for easy hardware revision and board porting.

// --- I2C Bus: MAX30102 Pulse Sensor & MPU6050 6-Axis IMU ---
constexpr uint8_t  PIN_I2C_SDA         = 21;    // ESP32 GPIO21 -> Sensors SDA
constexpr uint8_t  PIN_I2C_SCL         = 22;    // ESP32 GPIO22 -> Sensors SCL
constexpr uint32_t I2C_FREQUENCY_HZ    = 400000;// 400 kHz Fast-Mode I2C

// --- Hardware UART2: NEO-6M GPS Module ---
// Note: ESP32 RX2 connects to GPS Module TX, and ESP32 TX2 connects to GPS Module RX
constexpr uint8_t  PIN_GPS_RX          = 16;    // ESP32 GPIO16 (RX2) <- NEO-6M TX
constexpr uint8_t  PIN_GPS_TX          = 17;    // ESP32 GPIO17 (TX2) -> NEO-6M RX
constexpr uint32_t GPS_BAUDRATE        = 9600;  // Standard NMEA 9600 baud

// --- SPI Bus & Control: 2.8" ILI9341 Color TFT Display ---
constexpr uint8_t  PIN_TFT_CS          = 15;    // ESP32 GPIO15 -> TFT Chip Select
constexpr uint8_t  PIN_TFT_DC          = 2;     // ESP32 GPIO2  -> TFT Data/Command Select
constexpr uint8_t  PIN_TFT_RST         = 4;     // ESP32 GPIO4  -> TFT Hardware Reset
constexpr uint8_t  PIN_TFT_MOSI        = 23;    // ESP32 GPIO23 -> TFT SPI MOSI
constexpr uint8_t  PIN_TFT_SCLK        = 18;    // ESP32 GPIO18 -> TFT SPI SCK
constexpr uint8_t  PIN_TFT_MISO        = 19;    // ESP32 GPIO19 <- TFT SPI MISO

// --- Battery Voltage Monitoring ADC ---
// Connects to LiPo battery via high-impedance 2:1 resistive divider (100k / 100k ohm)
constexpr uint8_t  PIN_BATTERY_ADC     = 34;    // ESP32 GPIO34 (ADC1 Channel 6, Input Only)
constexpr float    BAT_DIVIDER_RATIO   = 2.0f;  // Ratio = (R1 + R2) / R2 = 2.0
constexpr float    BAT_ADC_REF_VOLT    = 3.3f;  // Nominal ADC reference voltage
constexpr uint16_t BAT_ADC_RESOLUTION  = 4095;  // 12-bit ADC range (0..4095)
constexpr float    BAT_FULL_VOLTS      = 4.20f; // 100% capacity LiPo cell
constexpr float    BAT_EMPTY_VOLTS     = 3.30f; // 0% safe cut-off LiPo cell

#endif // PINS_H
