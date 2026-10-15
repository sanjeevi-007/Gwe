#ifndef PACKETS_H
#define PACKETS_H

#include <stdint.h>
#include <stddef.h>

// Byte alignment packing directive
#pragma pack(push, 1)

// Common Header on every notification (9 bytes)
struct PacketHeader {
    uint8_t  ver;
    uint8_t  type;
    uint16_t seq;
    uint32_t t_ms;
    uint8_t  flags;
};

// Type 0x01 Pulse Packet (14 bytes total)
struct PulsePacket {
    PacketHeader header;
    uint16_t     bpm;
    uint8_t      spo2;
    uint8_t      quality;
    uint8_t      state;
};

// Type 0x02 Motion Packet (23 bytes total)
struct MotionPacket {
    PacketHeader header;
    int16_t      ax;
    int16_t      ay;
    int16_t      az;
    int16_t      gx;
    int16_t      gy;
    int16_t      gz;
    uint8_t      intensity;
    uint8_t      est_class;
};

// Type 0x03 GPS Packet (27 bytes with age_s / 25 bytes without age_s)
struct GpsPacket {
    PacketHeader header;
    uint8_t      fix;
    uint8_t      sats;
    int32_t      lat;
    int32_t      lon;
    uint16_t     hdop;
    uint32_t     utc;
    uint16_t     age_s;
};

// Type 0x04 AI Result Packet (14 bytes total)
struct AiPacket {
    PacketHeader header;
    uint8_t      label;
    uint8_t      score;
    uint16_t     model_ver;
    uint8_t      source;
};

// Type 0x05 Device Status Packet (18 bytes total)
struct StatusPacket {
    PacketHeader header;
    uint8_t      fw_major;
    uint8_t      fw_minor;
    uint8_t      fw_patch;
    uint8_t      sensors;
    uint32_t     uptime_s;
    uint8_t      battery;
};

// Writable Characteristic: Time Sync (4 bytes)
struct TimeSyncPacket {
    uint32_t epoch;
};

// Writable Characteristic: Config (3 bytes)
struct ConfigPacket {
    uint16_t notify_interval_ms;
    uint8_t  location_logging;
};

#pragma pack(pop)

// Static assertion size checks ensuring strict zero-padding binary layouts
static_assert(sizeof(PacketHeader) == 9, "PacketHeader size mismatch");
static_assert(sizeof(PulsePacket) == 14, "PulsePacket size mismatch");
static_assert(sizeof(MotionPacket) == 23, "MotionPacket size mismatch");
// Note: 9 (header) + 1 (fix) + 1 (sats) + 4 (lat) + 4 (lon) + 2 (hdop) + 4 (utc) + 2 (age_s) = 27 bytes.
static_assert(sizeof(GpsPacket) == 27 || sizeof(GpsPacket) == 25, "GpsPacket size mismatch");
static_assert(sizeof(AiPacket) == 14, "AiPacket size mismatch");
static_assert(sizeof(StatusPacket) == 18, "StatusPacket size mismatch");
static_assert(sizeof(TimeSyncPacket) == 4, "TimeSyncPacket size mismatch");
static_assert(sizeof(ConfigPacket) == 3, "ConfigPacket size mismatch");

#endif // PACKETS_H
