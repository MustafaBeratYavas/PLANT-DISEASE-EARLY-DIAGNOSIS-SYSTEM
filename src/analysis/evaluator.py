import time
import os
import numpy as np
import pandas as pd
import keras
import tensorflow as tf
from sklearn.metrics import classification_report

class Evaluator:
    def __init__(self,
                 model: keras.Model,
                 dataset: tf.data.Dataset,
                 class_names: list[str],
                 output_dir: str):
        # Store references
        self.model = model
        self.dataset = dataset
        self.class_names = class_names
        self.output_dir = output_dir

        # Build feature extractor
        self.feature_model = self._build_feature_extractor()

    def _build_feature_extractor(self) -> keras.Model:
        # Locate pooling layer
        try:
            target_layer = self.model.get_layer("global_average_pooling2d")
            output = target_layer.output
        except ValueError:
            output = self.model.layers[-2].output

        return keras.Model(inputs=self.model.input, outputs=output)

    def run(self) -> dict:
        # Initialize collectors
        y_true_accumulated = []
        y_prob = []
        features = []
        latencies = []

        print("Running Inference...")

        # Process batches with timing
        for images, labels in self.dataset:
            start = time.perf_counter()
            preds = self.model.predict(images, verbose=0)
            elapsed_ms = (time.perf_counter() - start) * 1000

            feats = self.feature_model.predict(images, verbose=0)

            # Record per-sample latency
            batch_size = len(images)
            per_sample = elapsed_ms / batch_size
            latencies.extend([per_sample] * batch_size)

            y_prob.extend(preds)
            y_true_accumulated.extend(labels.numpy())
            features.extend(feats)

        # Format results
        y_true_onehot = np.array(y_true_accumulated)
        y_prob = np.array(y_prob)
        features = np.array(features)

        y_true_indices = np.argmax(y_true_onehot, axis=1)
        y_pred_indices = np.argmax(y_prob, axis=1)
        y_prob_max = np.max(y_prob, axis=1)

        # Compute average latency
        avg_latency = float(np.mean(latencies))

        # Save evaluation reports
        self._save_reports(y_true_indices, y_pred_indices, avg_latency)

        # Return metrics dict
        return {
            "y_true": y_true_indices,
            "y_pred": y_pred_indices,
            "y_prob": y_prob,
            "y_prob_max": y_prob_max,
            "y_true_onehot": y_true_onehot,
            "latencies": latencies,
            "features": features
        }

    def _save_reports(self, y_true: np.ndarray, y_pred: np.ndarray, latency: float) -> None:
        # Generate classification report
        report_dict = classification_report(
            y_true,
            y_pred,
            target_names=self.class_names,
            output_dict=True,
            zero_division=0
        )
        report = pd.DataFrame(report_dict).transpose()
        report.to_csv(os.path.join(self.output_dir, "tables/classification_report.csv"))

        # Save inference specs
        specs = {
            'Single_Inference_Latency_ms': [latency],
            'Throughput_Samples_Per_Sec': [1000 / latency if latency > 0 else 0],
            'Total_Test_Samples': [len(y_true)],
            'Model_Params': [self.model.count_params()]
        }
        pd.DataFrame(specs).to_csv(
            os.path.join(self.output_dir, "tables/inference_specs.csv"), index=False
        )