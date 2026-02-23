import pytest
import numpy as np
from unittest.mock import patch, MagicMock

class TestPredictor:

    # Test valid model init
    @patch('keras.saving.load_model')
    def test_init_with_valid_paths(self, mock_load, sample_config, tmp_path):
        from inference import Predictor

        model_path = tmp_path / "model.keras"
        model_path.touch()

        labels_path = tmp_path / "labels.csv"
        labels_path.write_text("index,class_name\n0,Apple___healthy\n1,Tomato___healthy")

        sample_config['defaults']['model_path'] = str(model_path)

        with patch('src.core.config.ConfigLoader.load', return_value=sample_config):
            predictor = Predictor(
                model_path=str(model_path),
                config_path='configs/config.yaml',
                labels_path=str(labels_path)
            )

        assert len(predictor.class_names) == 2
        assert predictor.class_names[0] == 'Apple___healthy'

    # Test label ordering
    def test_load_labels_correct_order(self, tmp_path):
        from inference import Predictor

        labels_path = tmp_path / "labels.csv"
        labels_path.write_text(
            "index,class_name\n"
            "0,ClassA\n"
            "2,ClassC\n"
            "1,ClassB\n"
        )

        with patch.object(Predictor, '__init__', lambda x, *args, **kwargs: None):
            predictor = Predictor.__new__(Predictor)
            predictor.class_names = predictor._load_labels(str(labels_path))

        assert predictor.class_names == ['ClassA', 'ClassB', 'ClassC']

    # Test image preprocessing
    @patch('cv2.imread')
    @patch('cv2.cvtColor')
    @patch('cv2.resize')
    def test_preprocess_normalizes_correctly(
        self, mock_resize, mock_cvtcolor, mock_imread, sample_config
    ):
        from inference import Predictor

        mock_imread.return_value = np.zeros((100, 100, 3), dtype=np.uint8)
        mock_cvtcolor.return_value = np.zeros((100, 100, 3), dtype=np.uint8)
        mock_resize.return_value = np.full((224, 224, 3), 127, dtype=np.uint8)

        with patch.object(Predictor, '__init__', lambda x, *args, **kwargs: None):
            predictor = Predictor.__new__(Predictor)
            predictor.config = sample_config
            predictor.target_size = (224, 224)
            predictor.is_tflite = False

            result = predictor.preprocess('dummy.jpg')

        assert result.shape == (1, 224, 224, 3)

    # Test tflite preprocessing
    @patch('cv2.imread')
    @patch('cv2.cvtColor')
    @patch('cv2.resize')
    def test_preprocess_tflite_uint8(
        self, mock_resize, mock_cvtcolor, mock_imread, sample_config
    ):
        from inference import Predictor

        mock_imread.return_value = np.zeros((100, 100, 3), dtype=np.uint8)
        mock_cvtcolor.return_value = np.zeros((100, 100, 3), dtype=np.uint8)
        mock_resize.return_value = np.full((224, 224, 3), 127, dtype=np.uint8)

        with patch.object(Predictor, '__init__', lambda x, *args, **kwargs: None):
            predictor = Predictor.__new__(Predictor)
            predictor.config = sample_config
            predictor.target_size = (224, 224)
            predictor.is_tflite = True
            predictor.input_details = [{'dtype': np.uint8}]

            result = predictor.preprocess('dummy.jpg')

        assert result.shape == (1, 224, 224, 3)
        assert result.dtype == np.uint8


class TestPredictorIntegration:

    # Test prediction output
    @patch('keras.saving.load_model')
    def test_predict_returns_valid_output(
        self, mock_load, sample_config, temp_image_path, tmp_path
    ):
        from inference import Predictor

        mock_model = MagicMock()
        mock_model.predict.return_value = np.array([[0.1, 0.9]])
        mock_load.return_value = mock_model

        labels_path = tmp_path / "labels.csv"
        labels_path.write_text("index,class_name\n0,Diseased\n1,Healthy")

        model_path = tmp_path / "model.keras"
        model_path.touch()

        sample_config['defaults']['model_path'] = str(model_path)

        with patch('src.core.config.ConfigLoader.load', return_value=sample_config):
            predictor = Predictor(
                model_path=str(model_path),
                config_path='configs/config.yaml',
                labels_path=str(labels_path)
            )

            label, confidence = predictor.predict(temp_image_path)

        assert label == 'Healthy'
        assert 0.0 <= confidence <= 1.0