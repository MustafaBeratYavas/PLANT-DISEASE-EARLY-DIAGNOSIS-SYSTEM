import pytest

# Sample config fixture
@pytest.fixture
def sample_config():
    return {
        'data': {
            'img_size': [224, 224],
            'batch_size': 32,
            'seed': 42,
            'split_path': 'datasets/split',
            'raw_path': 'datasets/raw',
            'split_ratio': {'train': 0.8, 'val': 0.1, 'test': 0.1},
        },
        'model': {
            'base_model': 'MobileNetV3Large',
            'learning_rate_stage1': 0.001,
            'learning_rate_stage2': 0.0001,
            'epochs_stage1': 10,
            'epochs_stage2': 20,
            'patience': 5
        },
        'defaults': {
            'model_path': None
        }
    }

# Temporary image fixture
@pytest.fixture
def temp_image_path(tmp_path):
    import numpy as np
    from PIL import Image

    # Generate random test image
    img_array = np.random.randint(0, 255, (224, 224, 3), dtype=np.uint8)
    img = Image.fromarray(img_array)

    img_path = tmp_path / "test_image.jpg"
    img.save(img_path)

    return str(img_path)

# Mock class names fixture
@pytest.fixture
def mock_class_names():
    return [
        'Apple___Apple_scab',
        'Apple___Black_rot',
        'Apple___healthy',
        'Tomato___Early_blight',
        'Tomato___healthy'
    ]