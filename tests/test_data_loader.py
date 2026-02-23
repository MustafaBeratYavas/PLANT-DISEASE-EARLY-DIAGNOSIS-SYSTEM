import pytest
from unittest.mock import patch, MagicMock

class TestPlantDataLoader:

    # Test valid initialization
    def test_init_with_valid_config(self, sample_config):
        from src.data.loader import PlantDataLoader

        loader = PlantDataLoader(sample_config)

        assert loader.img_size == (224, 224)
        assert loader.batch_size == 32
        assert loader.data_dir == 'datasets/split'

    # Test invalid directory
    def test_get_dataset_invalid_directory(self, sample_config):
        from src.data.loader import PlantDataLoader

        loader = PlantDataLoader(sample_config)

        with pytest.raises(FileNotFoundError):
            loader.get_dataset('nonexistent_split')

    # Test shuffle parameter
    @patch('keras.utils.image_dataset_from_directory')
    def test_get_dataset_with_shuffle(self, mock_dataset, sample_config, tmp_path):
        from src.data.loader import PlantDataLoader

        split_dir = tmp_path / "train"
        split_dir.mkdir()
        (split_dir / "class1").mkdir()

        sample_config['data']['split_path'] = str(tmp_path)
        loader = PlantDataLoader(sample_config)

        mock_ds = MagicMock()
        mock_ds.map.return_value = mock_ds
        mock_ds.prefetch.return_value = mock_ds
        mock_dataset.return_value = mock_ds

        loader.get_dataset('train', shuffle=True)

        call_kwargs = mock_dataset.call_args[1]
        assert call_kwargs['shuffle'] is True

    # Test preprocessing applied
    @patch('keras.utils.image_dataset_from_directory')
    def test_preprocessing_applied(self, mock_dataset, sample_config, tmp_path):
        from src.data.loader import PlantDataLoader

        split_dir = tmp_path / "val"
        split_dir.mkdir()
        (split_dir / "class1").mkdir()

        sample_config['data']['split_path'] = str(tmp_path)
        loader = PlantDataLoader(sample_config)

        mock_ds = MagicMock()
        mock_ds.map.return_value = mock_ds
        mock_ds.prefetch.return_value = mock_ds
        mock_dataset.return_value = mock_ds

        loader.get_dataset('val')

        mock_ds.map.assert_called_once()


class TestConfigLoader:

    # Test valid YAML load
    def test_load_valid_yaml(self, tmp_path):
        from src.core.config import ConfigLoader

        config_path = tmp_path / "config.yaml"
        config_path.write_text("""
data:
  raw_path: datasets/raw
  split_path: datasets/split
  img_size: [224, 224]
  batch_size: 32
  seed: 42
model:
  base_model: MobileNetV3Large
  learning_rate_stage1: 0.001
  learning_rate_stage2: 0.0001
  epochs_stage1: 10
  epochs_stage2: 20
  patience: 3
""")

        config = ConfigLoader.load(str(config_path))

        assert config['data']['img_size'] == [224, 224]
        assert config['model']['base_model'] == 'MobileNetV3Large'

    # Test missing file error
    def test_load_missing_file(self):
        from src.core.config import ConfigLoader

        with pytest.raises(FileNotFoundError):
            ConfigLoader.load('nonexistent.yaml')

    # Test missing section error
    def test_load_missing_data_section(self, tmp_path):
        from src.core.config import ConfigLoader

        config_path = tmp_path / "bad_config.yaml"
        config_path.write_text("model:\n  base_model: test\n")

        with pytest.raises(ValueError, match="Missing config section"):
            ConfigLoader.load(str(config_path))

    # Test invalid split ratios
    def test_load_invalid_split_ratio(self, tmp_path):
        from src.core.config import ConfigLoader

        config_path = tmp_path / "bad_split.yaml"
        config_path.write_text("""
data:
  raw_path: datasets/raw
  split_path: datasets/split
  img_size: [224, 224]
  batch_size: 32
  split_ratio:
    train: 0.5
    val: 0.1
    test: 0.1
model:
  base_model: MobileNetV3Large
  learning_rate_stage1: 0.001
  learning_rate_stage2: 0.0001
  epochs_stage1: 10
  epochs_stage2: 20
""")

        with pytest.raises(ValueError, match="Split ratios must sum"):
            ConfigLoader.load(str(config_path))