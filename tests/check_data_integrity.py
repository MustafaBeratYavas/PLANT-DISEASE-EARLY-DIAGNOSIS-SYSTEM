import os
import pytest
import numpy as np
from pathlib import Path

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'

from src.core.config import ConfigLoader
from src.data.loader import PlantDataLoader

class TestDataIntegrity:
    # Validate data pipeline output.

    @pytest.fixture
    def data_pipeline(self):
        # Load training pipeline
        config_path = Path(__file__).resolve().parent.parent / 'configs' / 'config.yaml'
        config = ConfigLoader.load(str(config_path))
        loader = PlantDataLoader(config)
        return loader.get_dataset("train", shuffle=True)

    # Test batch diversity
    @pytest.mark.skipif(
        not os.path.exists('datasets/split/train'),
        reason="Dataset not available"
    )
    def test_shuffle_produces_diversity(self, data_pipeline):
        images, labels = next(iter(data_pipeline))
        unique_classes = len(np.unique(labels.numpy(), axis=0))
        assert unique_classes > 1, f"Only {unique_classes} class found, shuffle may be broken"

    # Test pixel normalization
    @pytest.mark.skipif(
        not os.path.exists('datasets/split/train'),
        reason="Dataset not available"
    )
    def test_pixel_range_normalized(self, data_pipeline):
        images, _ = next(iter(data_pipeline))
        max_pixel = float(np.max(images))
        min_pixel = float(np.min(images))

        assert max_pixel <= 1.0, f"Max pixel {max_pixel} exceeds 1.0"
        assert min_pixel >= -1.0, f"Min pixel {min_pixel} below -1.0"

    # Test batch shape
    @pytest.mark.skipif(
        not os.path.exists('datasets/split/train'),
        reason="Dataset not available"
    )
    def test_batch_shape_correct(self, data_pipeline):
        images, labels = next(iter(data_pipeline))
        assert len(images.shape) == 4, "Images must be 4D: [B, H, W, C]"
        assert images.shape[1] == 224
        assert images.shape[2] == 224
        assert images.shape[3] == 3