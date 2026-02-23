import os
import shutil
import random
from tqdm import tqdm
from pathlib import Path
from src.core.config import ConfigLoader

class DataPreparer:
    VALID_EXTENSIONS = {'.jpg', '.jpeg', '.png', '.bmp'}

    def __init__(self, config_path: str):
        # Load configuration
        config = ConfigLoader.load(config_path)

        # Store pipeline paths
        self.raw_path = Path(config['data']['raw_path'])
        self.split_path = Path(config['data']['split_path'])
        self.ratios = config['data']['split_ratio']
        self.seed = config['data']['seed']
        self.excluded = config['data'].get('excluded_classes', [])

    def clean_target(self) -> None:
        # Reset output directory
        if self.split_path.exists():
            shutil.rmtree(self.split_path)
        self.split_path.mkdir(parents=True)

    def split_data(self) -> None:
        # Set reproducibility seed
        random.seed(self.seed)
        if not self.raw_path.exists():
            raise FileNotFoundError(f"Path not found: {self.raw_path}")

        # Filter valid classes
        classes = [d.name for d in self.raw_path.iterdir() if d.is_dir()]
        classes = [c for c in classes if c not in self.excluded]
        classes.sort()

        print(f"Classes: {len(classes)}")

        # Process each class
        for class_name in tqdm(classes, desc="Processing"):
            src_dir = self.raw_path / class_name
            images = [f for f in src_dir.iterdir()
                      if f.suffix.lower() in self.VALID_EXTENSIONS]

            # Shuffle deterministically
            images.sort()
            random.shuffle(images)

            # Calculate split sizes
            n = len(images)
            n_train = int(n * self.ratios['train'])
            n_val = int(n * self.ratios['val'])

            splits = {
                'train': images[:n_train],
                'val': images[n_train:n_train + n_val],
                'test': images[n_train + n_val:]
            }

            # Copy files to splits
            for split_name, split_imgs in splits.items():
                dest_dir = self.split_path / split_name / class_name
                dest_dir.mkdir(parents=True, exist_ok=True)

                for img_path in split_imgs:
                    dest_file = dest_dir / img_path.name
                    try:
                        os.symlink(img_path.resolve(), dest_file)
                    except OSError:
                        shutil.copy(img_path, dest_file)

if __name__ == "__main__":
    # Run data preparation
    preparer = DataPreparer("configs/config.yaml")
    preparer.clean_target()
    preparer.split_data()