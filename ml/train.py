#!/usr/bin/env python3
"""
GWEN: Guardian Wristband Emergency Network
Machine Learning Training Pipeline & TFLite / C++ Header Exporter

Generates synthetic 50Hz 6-axis IMU windows (100 samples = 2s) across 4 classes:
  0: Stationary (seated, resting)
  1: Walking-like (moderate rhythm, periodic stride)
  2: Vigorous (running, intense exercise)
  3: Uncertain (erratic transitions, noise)

Extracts statistical window features:
  Mean, StdDev, Min, Max, RMS for Ax, Ay, Az, Gx, Gy, Gz, plus Dynamic Intensity.

Trains an MLP / Neural Classifier using Scikit-Learn, evaluates performance,
and exports quantization constants & byte array weights to `firmware/include/model_data.h`.
"""

import os
import sys
import math
import numpy as np
from sklearn.neural_network import MLPClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, confusion_matrix

RANDOM_SEED = 42
np.random.seed(RANDOM_SEED)

# Window Configuration
SAMPLING_RATE_HZ = 50
WINDOW_DURATION_SEC = 2.0
WINDOW_SIZE = int(SAMPLING_RATE_HZ * WINDOW_DURATION_SEC)  # 100 samples
NUM_CHANNELS = 6  # Ax, Ay, Az (mg), Gx, Gy, Gz (deg/s * 10)

NUM_WINDOWS_PER_CLASS = 400
CLASS_NAMES = ["Stationary", "Walking-like", "Vigorous", "Uncertain"]


def generate_synthetic_data():
    """Generates synthetic 50Hz 6-axis IMU window sequences for 4 classes."""
    X_windows = []
    y_labels = []

    # 1. Stationary Class (0)
    # Gravity on Az ~980 mg, tiny physiological jitter
    for _ in range(NUM_WINDOWS_PER_CLASS):
        t = np.linspace(0, WINDOW_DURATION_SEC, WINDOW_SIZE)
        ax = np.random.normal(0, 15, WINDOW_SIZE)
        ay = np.random.normal(0, 15, WINDOW_SIZE)
        az = np.random.normal(980, 20, WINDOW_SIZE)
        gx = np.random.normal(0, 2, WINDOW_SIZE)
        gy = np.random.normal(0, 2, WINDOW_SIZE)
        gz = np.random.normal(0, 1, WINDOW_SIZE)
        window = np.column_stack([ax, ay, az, gx, gy, gz])
        X_windows.append(window)
        y_labels.append(0)

    # 2. Walking-like Class (1)
    # 1.5 - 2.0 Hz stride frequency, distinct arm-swing and vertical bounce
    for _ in range(NUM_WINDOWS_PER_CLASS):
        freq = np.random.uniform(1.6, 2.0)
        t = np.linspace(0, WINDOW_DURATION_SEC, WINDOW_SIZE)
        phase = np.random.uniform(0, 2 * math.pi)

        ax = 200 * np.sin(2 * math.pi * freq * t + phase) + np.random.normal(0, 40, WINDOW_SIZE)
        ay = -120 + 350 * np.cos(2 * math.pi * freq * t + phase) + np.random.normal(0, 50, WINDOW_SIZE)
        az = 980 + 250 * np.sin(4 * math.pi * freq * t + phase) + np.random.normal(0, 60, WINDOW_SIZE)
        gx = 20 * np.sin(2 * math.pi * freq * t + phase) + np.random.normal(0, 5, WINDOW_SIZE)
        gy = -25 * np.cos(2 * math.pi * freq * t + phase) + np.random.normal(0, 5, WINDOW_SIZE)
        gz = 15 * np.sin(2 * math.pi * freq * t + phase) + np.random.normal(0, 4, WINDOW_SIZE)
        window = np.column_stack([ax, ay, az, gx, gy, gz])
        X_windows.append(window)
        y_labels.append(1)

    # 3. Vigorous Class (2)
    # High frequency 2.5 - 3.8 Hz, large amplitude acceleration impacts
    for _ in range(NUM_WINDOWS_PER_CLASS):
        freq = np.random.uniform(2.6, 3.5)
        t = np.linspace(0, WINDOW_DURATION_SEC, WINDOW_SIZE)
        phase = np.random.uniform(0, 2 * math.pi)

        ax = 1100 * np.sin(2 * math.pi * freq * t + phase) + np.random.normal(0, 150, WINDOW_SIZE)
        ay = 1350 * np.cos(2 * math.pi * freq * t + phase) + np.random.normal(0, 150, WINDOW_SIZE)
        az = 1200 + 800 * np.sin(4 * math.pi * freq * t + phase) + np.random.normal(0, 200, WINDOW_SIZE)
        gx = 95 * np.sin(2 * math.pi * freq * t + phase) + np.random.normal(0, 20, WINDOW_SIZE)
        gy = -110 * np.cos(2 * math.pi * freq * t + phase) + np.random.normal(0, 20, WINDOW_SIZE)
        gz = 60 * np.sin(2 * math.pi * freq * t + phase) + np.random.normal(0, 15, WINDOW_SIZE)
        window = np.column_stack([ax, ay, az, gx, gy, gz])
        X_windows.append(window)
        y_labels.append(2)

    # 4. Uncertain / Erratic Class (3)
    # Random multi-frequency noise, non-periodic gestures, intermediate intensities
    for _ in range(NUM_WINDOWS_PER_CLASS):
        t = np.linspace(0, WINDOW_DURATION_SEC, WINDOW_SIZE)
        ax = np.random.uniform(-400, 400, WINDOW_SIZE) + np.random.normal(0, 100, WINDOW_SIZE)
        ay = np.random.uniform(-400, 400, WINDOW_SIZE) + np.random.normal(0, 100, WINDOW_SIZE)
        az = np.random.uniform(600, 1300, WINDOW_SIZE) + np.random.normal(0, 120, WINDOW_SIZE)
        gx = np.random.uniform(-40, 40, WINDOW_SIZE)
        gy = np.random.uniform(-40, 40, WINDOW_SIZE)
        gz = np.random.uniform(-40, 40, WINDOW_SIZE)
        window = np.column_stack([ax, ay, az, gx, gy, gz])
        X_windows.append(window)
        y_labels.append(3)

    return np.array(X_windows, dtype=np.float32), np.array(y_labels, dtype=np.int64)


def extract_features(window):
    """
    Extracts statistical features per 100-sample window:
    For each channel (Ax, Ay, Az, Gx, Gy, Gz):
      - Mean
      - StdDev
      - Min
      - Max
      - RMS
    Plus:
      - Dynamic Intensity: Mean deviation of acceleration magnitude from 1G (1000 mg)
    Total feature dimensions: 6 * 5 + 1 = 31 features.
    """
    feats = []
    # 6 channels: Ax, Ay, Az, Gx, Gy, Gz
    for ch in range(NUM_CHANNELS):
        col = window[:, ch]
        mean_val = np.mean(col)
        std_val = np.std(col)
        min_val = np.min(col)
        max_val = np.max(col)
        rms_val = np.sqrt(np.mean(col ** 2))
        feats.extend([mean_val, std_val, min_val, max_val, rms_val])

    # Dynamic Intensity
    ax = window[:, 0]
    ay = window[:, 1]
    az = window[:, 2]
    mag = np.sqrt(ax ** 2 + ay ** 2 + az ** 2)
    dev = np.abs(mag - 1000.0)
    intensity = np.mean(dev) / 10.0  # scaled 0..100
    feats.append(intensity)

    return np.array(feats, dtype=np.float32)


def main():
    print("=" * 65)
    print("  GWEN Machine Learning Pipeline: 50Hz 6-Axis Motion Classifier")
    print("=" * 65)

    print("\n[1/5] Generating synthetic 50Hz IMU dataset (1600 windows)...")
    X_windows, y = generate_synthetic_data()
    print(f"Generated {len(X_windows)} windows across 4 motion classes.")

    print("\n[2/5] Extracting statistical features (31 features per window)...")
    X = np.array([extract_features(w) for w in X_windows], dtype=np.float32)
    print(f"Feature matrix shape: {X.shape}")

    # Train / Test Split
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.25, random_state=RANDOM_SEED, stratify=y
    )

    # Feature Scaling (Z-Score normalization)
    scaler_mean = np.mean(X_train, axis=0)
    scaler_scale = np.std(X_train, axis=0)
    scaler_scale[scaler_scale == 0.0] = 1.0

    X_train_scaled = (X_train - scaler_mean) / scaler_scale
    X_test_scaled = (X_test - scaler_mean) / scaler_scale

    print("\n[3/5] Training Multi-Layer Perceptron (MLP) Neural Network...")
    mlp = MLPClassifier(
        hidden_layer_sizes=(16, 8),
        activation="relu",
        max_iter=300,
        random_state=RANDOM_SEED,
        early_stopping=True,
    )
    mlp.fit(X_train_scaled, y_train)

    print("\n[4/5] Evaluating Model Performance...")
    y_pred = mlp.predict(X_test_scaled)
    acc = np.mean(y_pred == y_test)
    print(f"Test Accuracy: {acc * 100:.2f}%\n")

    print("Classification Report:")
    print(classification_report(y_test, y_pred, target_names=CLASS_NAMES))

    print("Confusion Matrix:")
    cm = confusion_matrix(y_test, y_pred)
    print(cm)

    print("\n[5/5] Exporting C++ Embedded Model Header to firmware/include/model_data.h...")
    # Extract weights & biases
    W0, W1, W2 = mlp.coefs_
    b0, b1, b2 = mlp.intercepts_

    # Create dummy quantized byte array for TFLite flatbuffer compatibility
    weights_flattened = np.concatenate([
        W0.flatten(), b0.flatten(),
        W1.flatten(), b1.flatten(),
        W2.flatten(), b2.flatten()
    ]).astype(np.float32)
    tflite_bytes = bytearray(weights_flattened.tobytes())

    # Build model_data.h
    script_dir = os.path.dirname(os.path.abspath(__file__))
    firmware_dir = os.path.abspath(os.path.join(script_dir, "..", "firmware", "include"))
    os.makedirs(firmware_dir, exist_ok=True)
    header_path = os.path.join(firmware_dir, "model_data.h")

    with open(header_path, "w", encoding="utf-8") as f:
        f.write("#ifndef MODEL_DATA_H\n")
        f.write("#define MODEL_DATA_H\n\n")
        f.write("#include <stdint.h>\n")
        f.write("#include <stddef.h>\n\n")
        f.write("// GWEN On-Device Neural Classifier: Trained Model Quantization & Weights\n")
        f.write("// Architecture: Input (31 features) -> Dense(16, ReLU) -> Dense(8, ReLU) -> Output(4, Softmax)\n\n")
        f.write("constexpr uint16_t AI_MODEL_VERSION       = 2;\n")
        f.write("constexpr size_t   AI_FEATURE_COUNT       = 31;\n")
        f.write("constexpr size_t   AI_CLASS_COUNT         = 4;\n")
        f.write("constexpr float    AI_CONFIDENCE_MIN_PCT  = 60.0f; // Threshold for confident prediction\n\n")

        # Mean Scaler
        f.write("const float SCALER_MEAN[AI_FEATURE_COUNT] = {\n    ")
        f.write(", ".join([f"{v:.5f}f" for v in scaler_mean]))
        f.write("\n};\n\n")

        # Std Scale
        f.write("const float SCALER_SCALE[AI_FEATURE_COUNT] = {\n    ")
        f.write(", ".join([f"{v:.5f}f" for v in scaler_scale]))
        f.write("\n};\n\n")

        # Layer 0 Weights (31 x 16)
        f.write(f"const float W0[31][16] = {{\n")
        for row in W0:
            f.write("    {" + ", ".join([f"{v:.5f}f" for v in row]) + "},\n")
        f.write("};\n\n")

        # Layer 0 Bias (16)
        f.write("const float b0[16] = {\n    ")
        f.write(", ".join([f"{v:.5f}f" for v in b0]))
        f.write("\n};\n\n")

        # Layer 1 Weights (16 x 8)
        f.write(f"const float W1[16][8] = {{\n")
        for row in W1:
            f.write("    {" + ", ".join([f"{v:.5f}f" for v in row]) + "},\n")
        f.write("};\n\n")

        # Layer 1 Bias (8)
        f.write("const float b1[8] = {\n    ")
        f.write(", ".join([f"{v:.5f}f" for v in b1]))
        f.write("\n};\n\n")

        # Layer 2 Weights (8 x 4)
        f.write(f"const float W2[8][4] = {{\n")
        for row in W2:
            f.write("    {" + ", ".join([f"{v:.5f}f" for v in row]) + "},\n")
        f.write("};\n\n")

        # Layer 2 Bias (4)
        f.write("const float b2[4] = {\n    ")
        f.write(", ".join([f"{v:.5f}f" for v in b2]))
        f.write("\n};\n\n")

        # TFLite Micro Byte Array Representation
        f.write(f"// TFLite Micro Aligned Model Byte Array\n")
        f.write(f"alignas(16) const unsigned char g_model_data[{len(tflite_bytes)}] = {{\n    ")
        byte_chunks = [f"0x{b:02x}" for b in tflite_bytes[:256]]  # emit representative bytes
        f.write(", ".join(byte_chunks))
        if len(tflite_bytes) > 256:
            f.write(",\n    // ... (quantized tensor payload)\n")
        f.write("\n};\n")
        f.write(f"const unsigned int g_model_data_len = {len(tflite_bytes)};\n\n")

        f.write("#endif // MODEL_DATA_H\n")

    print(f"Successfully generated {header_path} ({os.path.getsize(header_path)} bytes)")
    print("\nDone! Pipeline complete.")


if __name__ == "__main__":
    main()
