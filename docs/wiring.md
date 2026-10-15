# GWEN Puck Hardware Wiring & Pinout Guide

This document describes the complete hardware schematics, pin mappings, power routing, and circuit connections for assembling the **GWEN Puck** (ESP32-WROOM-32 standalone wearable node).

---

## 1. Complete Pinout Table

All pin assignments are defined in [`firmware/include/pins.h`](../firmware/include/pins.h).

| Module | Module Pin | ESP32 GPIO | Bus / Protocol | Voltage Level | Notes / Function |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **MAX30102** | VCC | 3.3V | Power | 3.3V | Optical heart rate sensor |
| | GND | GND | Power | 0V | Common ground |
| | SDA | GPIO 21 | I2C Data | 3.3V | Shared with MPU6050 (4.7kΩ pull-up to 3.3V) |
| | SCL | GPIO 22 | I2C Clock | 3.3V | Shared with MPU6050 (4.7kΩ pull-up to 3.3V) |
| | INT | NC | Interrupt | — | Not connected in default polling mode |
| **MPU6050** | VCC | 3.3V | Power | 3.3V | 6-Axis Accelerometer & Gyroscope |
| | GND | GND | Power | 0V | Common ground |
| | SDA | GPIO 21 | I2C Data | 3.3V | Shared I2C bus |
| | SCL | GPIO 22 | I2C Clock | 3.3V | Shared I2C bus |
| | AD0 | GND | Address Select | 0V | Sets I2C 7-bit address to `0x68` |
| | INT | NC | Interrupt | — | Optional |
| **NEO-6M GPS**| VCC | 5V / 3.3V | Power | 3.3V - 5.0V | Uses onboard 3.3V LDO regulator |
| | GND | GND | Power | 0V | Common ground |
| | TX | GPIO 16 | UART2 RX | 3.3V | **UART Cross**: GPS TX connects to ESP32 RX2 |
| | RX | GPIO 17 | UART2 TX | 3.3V | **UART Cross**: GPS RX connects to ESP32 TX2 |
| **ILI9341 2.8"**| VCC | 3.3V / 5V | Power | 3.3V or 5V | If 5V, ensure J1/VCC jumper is set correctly |
| | GND | GND | Power | 0V | Common ground |
| | CS | GPIO 15 | SPI Chip Select | 3.3V | Display active-low chip select |
| | RESET | GPIO 4 | Hardware Reset | 3.3V | Display hardware reset line |
| | DC / RS | GPIO 2 | Command / Data | 3.3V | Data (High) vs Command (Low) |
| | SDI (MOSI) | GPIO 23 | SPI MOSI | 3.3V | Hardware VSPI Data Out |
| | SCK (CLK) | GPIO 18 | SPI Clock | 3.3V | Hardware VSPI Clock (up to 40MHz) |
| | LED (BLK) | 3.3V (via 100Ω) | Backlight | 3.3V | Screen backlight brightness |
| | SDO (MISO) | GPIO 19 | SPI MISO | 3.3V | Optional display read-back |
| **Battery ADC**| BAT+ | GPIO 34 | Analog Input | 0 - 2.1V Max | Connected via 2:1 resistive divider (100kΩ/100kΩ) |
| | BAT- | GND | Power | 0V | Common battery ground |

---

## 2. Power Guidance: 3.3V vs 5V & Ground Sharing

> [!CAUTION]
> **ESP32 GPIO pins are strictly 3.3V logic tolerant!** Applying 5V directly to any ESP32 GPIO pin will permanently destroy the microcontroller.

### 3.3V Power Rail
- **MAX30102**: Must be supplied with **3.3V only**. Some breakout boards have an onboard 1.8V/3.3V LDO for the optical LEDs. Do not feed 5V into the MAX30102 VIN.
- **MPU6050**: Operates at 3.3V. While some GY-521 modules include a 5V-to-3.3V regulator on board, powering via the clean 3.3V rail avoids noise injection into the analog gyro filters.

### 5V vs 3.3V on NEO-6M GPS & ILI9341 TFT
- **NEO-6M GPS**: The u-blox NEO-6M module chip operates at 3.3V internally. Typical breakout boards include a 3.3V regulator on `VCC`. You can power it from the ESP32 `VIN` (5V USB rail) or `3.3V` pin (if your ESP32 board's 3.3V LDO provides $\ge 500\text{mA}$). The TX and RX communication lines are 3.3V logic compatible.
- **ILI9341 Display**: The logic lines (CS, DC, SCLK, MOSI) **must never exceed 3.3V**. Powering the screen VCC with 3.3V or 5V depends on whether the breakout includes an onboard LDO.

### Ground Sharing
- **All grounds (GND) must be tied together into a single common ground bus.**
- The battery ground, sensor ground, GPS ground, display ground, and ESP32 ground must share low-impedance copper connections to prevent ground loops and erroneous ADC readings.

---

## 3. UART Pin Swapping (Crossed Connections)

A common assembly error is wiring TX to TX and RX to RX. Serial UART communication requires crossed lines:

```
+--------------------+               +--------------------+
|     ESP32 Puck     |               |   NEO-6M GPS Module|
|                    |               |                    |
|  GPIO 16 (RX2) <----------------------- TX              |
|                    |               |                    |
|  GPIO 17 (TX2) -----------------------> RX              |
|                    |               |                    |
|       GND    <------------------------> GND             |
+--------------------+               +--------------------+
```

- **ESP32 GPIO 16 (RX2)** receives NMEA 0183 sentences emitted by **GPS TX**.
- **ESP32 GPIO 17 (TX2)** sends configuration packets (e.g. 5Hz refresh rate commands) into **GPS RX**.

---

## 4. Battery Monitoring Voltage Divider Circuit

A single-cell Lithium Polymer (LiPo) battery outputs:
- **4.20V** when fully charged.
- **3.70V** nominal voltage.
- **3.30V** empty cut-off voltage.

Because ESP32 GPIO34 ADC can only accept up to **3.3V** (and nonlinear saturation occurs above ~2.6V with certain attenuation settings), a symmetrical **2:1 resistive divider** is used:

```
            LiPo BAT+ (3.3V - 4.2V)
                 |
                 |
               [ R1 ]  100 kΩ (1% tolerance)
                 |
                 +------> To ESP32 GPIO 34 (ADC1_CH6)  [0V - 2.10V]
                 |
               [ R2 ]  100 kΩ (1% tolerance)
                 |
                 |
                GND
```

### Circuit Specifications
- **Resistor values**: $R_1 = 100\text{ k}\Omega$, $R_2 = 100\text{ k}\Omega$ (1% metal film resistors).
  - High resistance minimises parasitic quiescent drain on the battery ($I_{\text{leak}} = \frac{4.2\text{V}}{200\text{k}\Omega} = 21\,\mu\text{A}$).
- **Voltage Scaling Ratio**:
  $$V_{\text{ADC}} = V_{\text{BAT}} \times \left(\frac{R_2}{R_1 + R_2}\right) = V_{\text{BAT}} \times 0.5$$
- **At 4.20V max battery**: $V_{\text{ADC}} = 2.10\text{V}$ (well within safe ADC limits).
- **At 3.30V cutoff battery**: $V_{\text{ADC}} = 1.65\text{V}$.

### ADC Conversion Calculation
```cpp
// 12-bit ADC reading on GPIO 34 (0 - 4095)
const float pinVolts = (analogRead(PIN_BATTERY_ADC) / 4095.0f) * 3.3f;
const float batteryVolts = pinVolts * 2.0f; // Scale back by divider ratio (2.0)

// Percentage mapping (3.30V to 4.20V)
uint8_t batteryPct = 0;
if (batteryVolts >= 4.20f) {
    batteryPct = 100;
} else if (batteryVolts > 3.30f) {
    batteryPct = (uint8_t)(((batteryVolts - 3.30f) / (4.20f - 3.30f)) * 100.0f);
}
```

---

## 5. Summary Diagram

```
                       +-------------------+
                       |  ESP32-WROOM-32   |
                       |                   |
MAX30102 (PPG) <---I2C---> GPIO 21 (SDA)   |
MPU6050  (IMU) <---I2C---> GPIO 22 (SCL)   |
                       |                   |
NEO-6M GPS     <--UART---> GPIO 16 (RX2)   |
               <--UART---> GPIO 17 (TX2)   |
                       |                   |
ILI9341 2.8"   <---SPI---> GPIO 15 (CS)    |
Color TFT                  GPIO 2  (DC)    |
                           GPIO 4  (RST)   |
                           GPIO 18 (SCK)   |
                           GPIO 23 (MOSI)  |
                       |                   |
LiPo 100k/100k <--ADC----> GPIO 34 (ADC1)  |
                       +-------------------+
```
