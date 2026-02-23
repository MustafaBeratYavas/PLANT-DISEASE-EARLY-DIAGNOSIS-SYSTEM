import argparse
import csv
import os
import time

import cv2
import numpy as np

from src.core.config import ConfigLoader


class Predictor:
    def __init__(self,
                 model_path: str | None,
                 config_path: str,
                 labels_path: str | None = None):
        # Load configuration
        self.config = ConfigLoader.load(config_path)

        # Resolve model path
        if not model_path:
            model_path = self.config.get('defaults', {}).get('model_path')

        if not model_path or not os.path.exists(model_path):
            raise ValueError(f"Invalid model path: {model_path}")

        self.model_path = model_path
        self.target_size = tuple(self.config['data']['img_size'])
        self.is_tflite = model_path.endswith('.tflite')

        # Load inference engine
        if self.is_tflite:
            self._load_tflite_model()
        else:
            self._load_keras_model()

        # Load class labels
        if not labels_path:
            labels_path = self._find_labels(model_path)

        self.class_names = self._load_labels(labels_path)

    def _load_keras_model(self) -> None:
        # Initialize keras model
        import keras
        self.model = keras.saving.load_model(self.model_path)

    def _load_tflite_model(self) -> None:
        # Initialize tflite interpreter
        import tensorflow as tf
        self.interpreter = tf.lite.Interpreter(model_path=self.model_path)
        self.interpreter.allocate_tensors()
        self.input_details = self.interpreter.get_input_details()
        self.output_details = self.interpreter.get_output_details()

    def _find_labels(self, model_path: str) -> str:
        # Search parent directories
        candidates = [
            os.path.join(os.path.dirname(model_path), 'labels.csv'),
            os.path.join(os.path.dirname(os.path.dirname(model_path)), 'labels.csv')
        ]
        for path in candidates:
            if os.path.exists(path):
                return path
        raise FileNotFoundError("labels.csv not found")

    def _load_labels(self, path: str) -> list[str]:
        # Parse label mappings
        class_names = {}
        with open(path) as f:
            reader = csv.DictReader(f)
            for row in reader:
                class_names[int(row['index'])] = row['class_name']
        return [class_names[i] for i in range(len(class_names))]

    def preprocess(self, image_path: str) -> np.ndarray:
        # Read image file
        image = cv2.imread(image_path)
        if image is None:
            raise ValueError(f"Read error: {image_path}")

        # Apply color conversion
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        image = cv2.resize(image, self.target_size, interpolation=cv2.INTER_LINEAR)

        # Normalize for inference
        if self.is_tflite:
            input_dtype = self.input_details[0]['dtype']
            if input_dtype == np.uint8:
                return np.expand_dims(image.astype(np.uint8), axis=0)
            else:
                image = image.astype("float32")
                image = (image / 127.5) - 1.0
                return np.expand_dims(image, axis=0)
        else:
            from keras.applications.mobilenet_v3 import preprocess_input
            image = image.astype("float32")
            image = preprocess_input(image)
            return np.expand_dims(image, axis=0)

    def predict(self, image_path: str) -> tuple[str, float]:
        # Prepare input tensor
        input_tensor = self.preprocess(image_path)

        # Run model inference
        if self.is_tflite:
            predictions = self._predict_tflite(input_tensor)
        else:
            predictions = self.model.predict(input_tensor, verbose=0)[0]

        # Extract top prediction
        predicted_index = np.argmax(predictions)
        confidence = float(np.max(predictions))

        return self.class_names[predicted_index], confidence

    def _predict_tflite(self, input_tensor: np.ndarray) -> np.ndarray:
        # Execute tflite inference
        self.interpreter.set_tensor(self.input_details[0]['index'], input_tensor)
        self.interpreter.invoke()
        output = self.interpreter.get_tensor(self.output_details[0]['index'])
        return output[0]

if __name__ == "__main__":
    # Parse CLI arguments
    parser = argparse.ArgumentParser(description='Run Plant Disease Inference')
    parser.add_argument('--image', type=str, required=True, help='Path to image')
    parser.add_argument('--model', type=str, default=None, help='Path to model')
    parser.add_argument('--config', type=str, default='configs/config.yaml', help='Path to config')
    args = parser.parse_args()

    try:
        predictor = Predictor(args.model, args.config)

        # Measure inference latency
        start = time.perf_counter()
        label, score = predictor.predict(args.image)
        elapsed = (time.perf_counter() - start) * 1000

        print(f"Result: {label} ({score:.4f})")
        print(f"Latency: {elapsed:.2f} ms")
    except Exception as e:
        print(f"Error: {e}")
