import os
import keras
import numpy as np
from sklearn.utils import class_weight

class Trainer:
    def __init__(self,
                 model: keras.Model,
                 base_model: keras.Model,
                 train_ds,
                 val_ds,
                 config: dict,
                 output_dir: str):
        # Store training references
        self.model = model
        self.base_model = base_model
        self.train_ds = train_ds
        self.val_ds = val_ds
        self.config = config
        self.output_dir = output_dir

        # Setup training components
        self.callbacks = self._get_callbacks()
        self.class_weights = self._compute_class_weights()

    def _get_callbacks(self) -> list[keras.callbacks.Callback]:
        # Configure output paths
        checkpoint_dir = os.path.join(self.output_dir, 'checkpoints')
        log_dir = os.path.join(self.output_dir, 'tables')

        # Return training callbacks
        return [
            keras.callbacks.ModelCheckpoint(
                filepath=os.path.join(checkpoint_dir, 'best_model.keras'),
                save_best_only=True,
                monitor='val_accuracy',
                mode='max',
                verbose=1
            ),
            keras.callbacks.EarlyStopping(
                monitor='val_loss',
                patience=self.config['model']['patience'],
                restore_best_weights=True,
                verbose=1
            ),
            keras.callbacks.CSVLogger(
                os.path.join(log_dir, 'training_metrics.csv'),
                append=True
            )
        ]

    def _compute_class_weights(self) -> dict[int, float]:
        # Scan training directory
        train_dir = os.path.join(self.config['data']['split_path'], 'train')

        class_names = sorted([d for d in os.listdir(train_dir)
                              if os.path.isdir(os.path.join(train_dir, d))])

        # Count samples per class
        y_train = []
        for idx, class_name in enumerate(class_names):
            class_path = os.path.join(train_dir, class_name)
            with os.scandir(class_path) as it:
                num_files = sum(1 for entry in it if entry.is_file())
            y_train.extend([idx] * num_files)

        # Calculate balanced weights
        weights = class_weight.compute_class_weight(
            class_weight='balanced',
            classes=np.unique(y_train),
            y=y_train
        )
        return dict(enumerate(weights))

    def train(self) -> tuple[keras.callbacks.History, int]:
        # Stage 1: Head training
        optimizer_stage1 = keras.optimizers.Adam(
            learning_rate=self.config['model']['learning_rate_stage1']
        )

        self.model.compile(
            optimizer=optimizer_stage1,
            loss='categorical_crossentropy',
            metrics=['accuracy']
        )

        history_stage1 = self.model.fit(
            self.train_ds,
            validation_data=self.val_ds,
            epochs=self.config['model']['epochs_stage1'],
            callbacks=self.callbacks,
            class_weight=self.class_weights
        )

        # Stage 2: Fine-tuning backbone
        self.base_model.trainable = True

        # Freeze batch normalization
        for layer in self.base_model.layers:
            if isinstance(layer, keras.layers.BatchNormalization):
                layer.trainable = False

        optimizer_stage2 = keras.optimizers.Adam(
            learning_rate=self.config['model']['learning_rate_stage2']
        )

        self.model.compile(
            optimizer=optimizer_stage2,
            loss='categorical_crossentropy',
            metrics=['accuracy']
        )

        # Continue training epochs
        total_epochs = (self.config['model']['epochs_stage1']
                        + self.config['model']['epochs_stage2'])
        initial_epoch = len(history_stage1.history['loss'])

        history_stage2 = self.model.fit(
            self.train_ds,
            validation_data=self.val_ds,
            epochs=total_epochs,
            initial_epoch=initial_epoch,
            callbacks=self.callbacks,
            class_weight=self.class_weights
        )

        # Merge training histories
        merged_history = self._merge_histories(history_stage1, history_stage2)
        return merged_history, initial_epoch

    def _merge_histories(self,
                         h1: keras.callbacks.History,
                         h2: keras.callbacks.History) -> keras.callbacks.History:
        # Combine metric histories
        for key in h1.history:
            if key in h2.history:
                h1.history[key].extend(h2.history[key])

        # Combine epoch indices
        if hasattr(h1, 'epoch') and hasattr(h2, 'epoch'):
            h1.epoch.extend(h2.epoch)

        return h1