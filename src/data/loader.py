import os
import tensorflow as tf
import keras
from keras.applications.mobilenet_v3 import preprocess_input

class PlantDataLoader:
    def __init__(self, config: dict):
        # Parse data config params
        self.config = config
        self.img_size = tuple(config['data']['img_size'])
        self.batch_size = config['data']['batch_size']
        self.data_dir = config['data']['split_path']

    def get_dataset(self, split: str, shuffle: bool = False) -> tf.data.Dataset:
        # Validate split directory
        directory = os.path.join(self.data_dir, split)

        if not os.path.exists(directory):
            raise FileNotFoundError(f"Directory not found: {directory}")

        # Load image dataset
        ds = keras.utils.image_dataset_from_directory(
            directory,
            labels='inferred',
            label_mode='categorical',
            image_size=self.img_size,
            batch_size=self.batch_size,
            shuffle=shuffle,
            seed=self.config['data']['seed'],
            interpolation='bilinear'
        )

        # Apply MobileNetV3 preprocessing
        ds = ds.map(lambda x, y: (preprocess_input(x), y),
                    num_parallel_calls=tf.data.AUTOTUNE)

        # Optimize data pipeline
        return ds.prefetch(buffer_size=tf.data.AUTOTUNE)