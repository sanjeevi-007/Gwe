/**
 * GWEN Puck: On-Device AI Motion Classifier
 *
 * Runs forward pass inference of the trained Multi-Layer Perceptron (MLP)
 * on statistical features extracted from 50Hz 6-axis IMU window buffer.
 */

#include <math.h>
#include <string.h>
#include "ai_inference.h"
#include "model_data.h"

AiInferenceOutput runAiInference(const int16_t* accel, const int16_t* gyro) {
    // 100 samples in a 2-second window
    constexpr int WINDOW_LEN = 100;
    float features[AI_FEATURE_COUNT] = {0.0f};

    // Extract statistics across 6 channels:
    // 0: Ax, 1: Ay, 2: Az (from accel array), 3: Gx, 4: Gy, 5: Gz (from gyro array)
    for (int ch = 0; ch < 6; ch++) {
        float sum = 0.0f;
        float sumSq = 0.0f;
        float minVal = 1e9f;
        float maxVal = -1e9f;

        for (int i = 0; i < WINDOW_LEN; i++) {
            float val = (ch < 3)
                ? static_cast<float>(accel[i * 3 + ch])
                : static_cast<float>(gyro[i * 3 + (ch - 3)]);

            sum += val;
            sumSq += val * val;
            if (val < minVal) minVal = val;
            if (val > maxVal) maxVal = val;
        }

        const float mean = sum / WINDOW_LEN;
        const float variance = (sumSq / WINDOW_LEN) - (mean * mean);
        const float stdDev = (variance > 0.0f) ? sqrtf(variance) : 0.0f;
        const float rms = sqrtf(sumSq / WINDOW_LEN);

        const int offset = ch * 5;
        features[offset + 0] = mean;
        features[offset + 1] = stdDev;
        features[offset + 2] = minVal;
        features[offset + 3] = maxVal;
        features[offset + 4] = rms;
    }

    // Dynamic Intensity: mean deviation from 1000 mg
    float devSum = 0.0f;
    for (int i = 0; i < WINDOW_LEN; i++) {
        const float ax = static_cast<float>(accel[i * 3 + 0]);
        const float ay = static_cast<float>(accel[i * 3 + 1]);
        const float az = static_cast<float>(accel[i * 3 + 2]);
        const float mag = sqrtf(ax * ax + ay * ay + az * az);
        devSum += fabsf(mag - 1000.0f);
    }
    features[30] = (devSum / WINDOW_LEN) / 10.0f;

    // Normalize features using Z-score scaler constants
    float scaledFeatures[AI_FEATURE_COUNT];
    for (size_t i = 0; i < AI_FEATURE_COUNT; i++) {
        scaledFeatures[i] = (features[i] - SCALER_MEAN[i]) / SCALER_SCALE[i];
    }

    // Layer 0: Dense(31 -> 16, ReLU)
    float h0[16];
    for (int j = 0; j < 16; j++) {
        float act = b0[j];
        for (int i = 0; i < 31; i++) {
            act += scaledFeatures[i] * W0[i][j];
        }
        h0[j] = (act > 0.0f) ? act : 0.0f; // ReLU
    }

    // Layer 1: Dense(16 -> 8, ReLU)
    float h1[8];
    for (int j = 0; j < 8; j++) {
        float act = b1[j];
        for (int i = 0; i < 16; i++) {
            act += h0[i] * W1[i][j];
        }
        h1[j] = (act > 0.0f) ? act : 0.0f; // ReLU
    }

    // Layer 2: Dense(8 -> 4, Linear Logits)
    float logits[4];
    float maxLogit = -1e9f;
    for (int j = 0; j < 4; j++) {
        float act = b2[j];
        for (int i = 0; i < 8; i++) {
            act += h1[i] * W2[i][j];
        }
        logits[j] = act;
        if (act > maxLogit) maxLogit = act;
    }

    // Softmax probabilities
    float expSum = 0.0f;
    float probs[4];
    for (int j = 0; j < 4; j++) {
        probs[j] = expf(logits[j] - maxLogit);
        expSum += probs[j];
    }

    int bestClass = 0;
    float bestProb = 0.0f;
    for (int j = 0; j < 4; j++) {
        probs[j] /= expSum;
        if (probs[j] > bestProb) {
            bestProb = probs[j];
            bestClass = j;
        }
    }

    const float confidencePct = bestProb * 100.0f;

    AiInferenceOutput output;
    output.model_ver = AI_MODEL_VERSION; // 2
    output.source    = 2;                // 2 = Trained Neural Model

    // Fall back to uncertain (3) if confidence is below 60%
    if (confidencePct < AI_CONFIDENCE_MIN_PCT) {
        output.label = 3; // Uncertain
        output.score = static_cast<uint8_t>(confidencePct);
    } else {
        output.label = static_cast<uint8_t>(bestClass);
        output.score = static_cast<uint8_t>(confidencePct);
    }

    return output;
}
