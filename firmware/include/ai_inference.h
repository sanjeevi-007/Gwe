#ifndef AI_INFERENCE_H
#define AI_INFERENCE_H

#include <stdint.h>
#include "packets.h"

/// Output result of on-device neural inference.
struct AiInferenceOutput {
    uint8_t  label;       // 0: stationary, 1: walking-like, 2: vigorous, 3: uncertain
    uint8_t  score;       // Confidence score 0..100%
    uint16_t model_ver;   // Model version (2)
    uint8_t  source;      // 2 = Trained Neural Model (per CONTRACTS.md)
};

/**
 * Runs on-device neural classification on 100-sample 50Hz 6-axis IMU window.
 *
 * @param accel Array of 100 3-axis accelerometer readings (Ax, Ay, Az in mg, 300 elements total).
 * @param gyro  Array of 100 3-axis gyroscope readings (Gx, Gy, Gz in deg/s * 10, 300 elements total).
 * @return AiInferenceOutput with predicted class label and confidence score.
 */
AiInferenceOutput runAiInference(const int16_t* accel, const int16_t* gyro);

#endif // AI_INFERENCE_H
