import keras

class PlantModel:
    def __init__(self, config: dict, num_classes: int):
        # Store model configuration
        self.input_shape = (*config['data']['img_size'], 3)
        self.num_classes = num_classes
        self.model_name = config['model']['base_model']

        # Define augmentation layers
        self.data_augmentation = keras.Sequential([
            keras.layers.RandomFlip("horizontal_and_vertical"),
            keras.layers.RandomRotation(0.2),
            keras.layers.RandomZoom(0.2),
            keras.layers.RandomContrast(0.2),
        ])

    def build(self) -> tuple[keras.Model, keras.Model]:
        # Load pretrained backbone
        base_model_class = getattr(keras.applications, self.model_name)

        base_model = base_model_class(
            input_shape=self.input_shape,
            include_top=False,
            weights='imagenet'
        )

        # Freeze backbone weights
        base_model.trainable = False

        # Build classifier head
        inputs = keras.Input(shape=self.input_shape)
        x = self.data_augmentation(inputs)
        x = base_model(x, training=False)
        x = keras.layers.GlobalAveragePooling2D()(x)
        x = keras.layers.Dropout(0.2)(x)
        outputs = keras.layers.Dense(self.num_classes, activation='softmax')(x)

        # Assemble full model
        model = keras.Model(inputs, outputs)
        return model, base_model