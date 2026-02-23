import argparse
import csv
import os
import shutil
from pathlib import Path

import tensorflow as tf

from src.core.config import ConfigLoader
from src.data.loader import PlantDataLoader


def convert_to_tflite(model_path: str, output_dir: str, config: dict) -> None:
    # Load trained keras model
    print(f"Converting model: {model_path}")
    model = tf.keras.models.load_model(model_path)
    model_name = Path(model_path).stem

    # Configure base converter
    converter = tf.lite.TFLiteConverter.from_keras_model(model)

    # Export float32 model
    tflite_model = converter.convert()
    fp32_path = Path(output_dir) / f"{model_name}.tflite"

    with open(fp32_path, "wb") as f:
        f.write(tflite_model)
    print(f"Standard model saved: {fp32_path}")

    # Build representative dataset
    rep_gen = _build_representative_dataset(config)

    # Configure full integer quantization
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.representative_dataset = rep_gen
    converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
    converter.inference_input_type = tf.uint8
    converter.inference_output_type = tf.float32

    # Export quantized model
    tflite_quant_model = converter.convert()
    quant_path = Path(output_dir) / f"{model_name}_quantized.tflite"

    with open(quant_path, "wb") as f:
        f.write(tflite_quant_model)
    print(f"Optimized model saved: {quant_path}")

    # Deploy to mobile assets
    _copy_assets_to_mobile(quant_path)

    # Print size comparison
    print("-" * 30)
    print(f"Original Size: {fp32_path.stat().st_size / 1024 / 1024:.2f} MB")
    print(f"Optimized Size: {quant_path.stat().st_size / 1024 / 1024:.2f} MB")

def _build_representative_dataset(config: dict):
    # Load calibration samples
    loader = PlantDataLoader(config)
    train_ds = loader.get_dataset("train", shuffle=True)

    # Yield representative samples
    def representative_gen():
        for images, _ in train_ds.take(100):
            for i in range(images.shape[0]):
                sample = tf.expand_dims(images[i], axis=0)
                yield [sample]

    return representative_gen

def _copy_assets_to_mobile(model_source_path: Path) -> None:
    # Resolve target paths
    project_root = Path(__file__).resolve().parent
    mobile_assets = project_root / "mobile" / "assets"
    mobile_models = mobile_assets / "models"

    if not mobile_assets.exists():
        print("Warning: Mobile directory structure not found. Skipping copy.")
        return

    mobile_models.mkdir(parents=True, exist_ok=True)

    # Copy model file
    model_dest = mobile_models / "best_model_quantized.tflite"
    shutil.copy2(model_source_path, model_dest)
    print(f"Copied model to mobile: {model_dest}")

    # Generate labels.txt
    source_labels = model_source_path.parent.parent / "labels.csv"

    if source_labels.exists():
        labels_dest = mobile_assets / "labels.txt"

        with open(source_labels) as f_csv, open(labels_dest, 'w') as f_txt:
            reader = csv.DictReader(f_csv)
            for row in reader:
                f_txt.write(f"{row['class_name']}\n")

        print(f"Generated labels.txt: {labels_dest}")
    else:
        print("Warning: labels.csv not found.")

if __name__ == "__main__":
    # Parse CLI arguments
    parser = argparse.ArgumentParser(description='Export TFLite Model')
    parser.add_argument('--model', default=None, help='Path to Keras model')
    parser.add_argument('--config', default="configs/config.yaml", help='Path to config')
    args = parser.parse_args()

    # Load configuration
    config = ConfigLoader.load(args.config)

    # Resolve model path
    model_path = args.model
    if model_path is None:
        model_path = config.get('defaults', {}).get('model_path')

    if model_path is None:
        raise ValueError("Model path required via CLI or config defaults")

    output_dir = os.path.dirname(model_path)
    convert_to_tflite(model_path, output_dir, config)
