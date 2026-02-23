import argparse
import os
import csv
import keras
from src.core.config import ConfigLoader
from src.data.loader import PlantDataLoader
from src.analysis.evaluator import Evaluator
from src.analysis.visualizer import Visualizer

def load_labels(path: str) -> list[str]:
    # Parse label CSV file
    class_names = {}
    with open(path, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            class_names[int(row['index'])] = row['class_name']
    return [class_names[i] for i in range(len(class_names))]

def evaluate(model_path: str | None, config_path: str) -> None:
    # Load configuration
    config = ConfigLoader.load(config_path)

    # Resolve model path
    if model_path is None:
        model_path = config.get('defaults', {}).get('model_path')
        if model_path is None:
            raise ValueError("Model path not provided in CLI args or config.yaml")

    print(f"Loading model from: {model_path}")

    # Load trained model
    model = keras.saving.load_model(model_path)

    # Resolve class labels
    version_dir = os.path.dirname(os.path.dirname(model_path))
    labels_path = os.path.join(version_dir, 'labels.csv')

    if os.path.exists(labels_path):
        class_names = load_labels(labels_path)
    else:
        train_dir = os.path.join(config['data']['split_path'], 'train')
        class_names = sorted(os.listdir(train_dir))

    # Prepare test dataset
    loader = PlantDataLoader(config)
    test_ds = loader.get_dataset("test", shuffle=False)

    # Run evaluation pipeline
    evaluator = Evaluator(model, test_ds, class_names, version_dir)
    results = evaluator.run()

    # Generate evaluation plots
    print("Generating Plots...")
    viz = Visualizer(version_dir, config)

    viz.plot_confusion_matrix(results["y_true"], results["y_pred"], class_names)
    viz.plot_pr_curve(results["y_true_onehot"], results["y_prob"], class_names)
    viz.plot_roc_curve(results["y_true_onehot"], results["y_prob"], class_names)
    viz.plot_top_k_accuracy(results["y_true"], results["y_prob"])
    viz.plot_latency_histogram(results["latencies"])
    viz.plot_confidence_calibration(results["y_true"], results["y_pred"], results["y_prob_max"])
    viz.plot_tsne(results["features"], results["y_true"], class_names)
    viz.plot_class_f1_scores(os.path.join(version_dir, "tables/classification_report.csv"))

    # Plot class balance
    train_dir = os.path.join(config['data']['split_path'], 'train')
    if os.path.exists(train_dir):
        counts = [len(os.listdir(os.path.join(train_dir, c))) for c in class_names]
        total = sum(counts)
        weights = [total / (len(class_names) * c) for c in counts]
        viz.plot_data_balance(counts, weights, class_names)

    print(f"Evaluation Complete. Results saved to {version_dir}")

if __name__ == "__main__":
    # Parse CLI arguments
    parser = argparse.ArgumentParser(description='Evaluate Plant Disease Model')
    parser.add_argument('--model', default=None, help='Path to trained model')
    parser.add_argument('--config', default="configs/config.yaml", help='Path to config')
    args = parser.parse_args()
    evaluate(args.model, args.config)