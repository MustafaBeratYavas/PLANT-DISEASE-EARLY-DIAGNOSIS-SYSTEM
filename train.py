import argparse
import csv
import logging
import os
import sys

from src.analysis.visualizer import Visualizer
from src.core.config import ConfigLoader
from src.core.paths import PathManager
from src.data.loader import PlantDataLoader
from src.modeling.net import PlantModel
from src.modeling.trainer import Trainer

# Configure log format
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def main() -> None:
    # Parse CLI arguments
    parser = argparse.ArgumentParser(description='Train PlantVillage Model')
    parser.add_argument('--config', type=str, default='configs/config.yaml', help='Path to config')
    args = parser.parse_args()

    try:
        # Load configuration
        config = ConfigLoader.load(args.config)
        path_manager = PathManager(config)

        # Initialize data pipeline
        loader = PlantDataLoader(config)
        train_ds = loader.get_dataset("train", shuffle=True)
        val_ds = loader.get_dataset("val")

        # Resolve class names
        train_dir = os.path.join(config['data']['split_path'], 'train')
        if not os.path.exists(train_dir):
            raise FileNotFoundError(f"Train directory not found: {train_dir}")

        class_names = sorted([d for d in os.listdir(train_dir)
                              if os.path.isdir(os.path.join(train_dir, d))])
        num_classes = len(class_names)

        # Export label mappings
        labels_path = os.path.join(path_manager.version_dir, 'labels.csv')
        os.makedirs(os.path.dirname(labels_path), exist_ok=True)

        with open(labels_path, 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(['index', 'class_name'])
            for idx, name in enumerate(class_names):
                writer.writerow([idx, name])

        logging.info(f"Training {num_classes} classes. Labels: {labels_path}")

        # Build model architecture
        model_wrapper = PlantModel(config, num_classes)
        model, base_model = model_wrapper.build()

        # Execute training pipeline
        trainer = Trainer(model, base_model, train_ds, val_ds, config, path_manager.version_dir)
        history, transition_epoch = trainer.train()

        # Save training plots
        viz = Visualizer(path_manager.version_dir, config)
        viz.save_training_history(history, transition_epoch)

    except Exception as e:
        logging.error(f"Training failed: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'
    main()
