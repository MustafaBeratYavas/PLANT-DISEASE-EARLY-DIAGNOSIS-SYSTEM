import yaml


class ConfigLoader:
    @staticmethod
    def load(path: str) -> dict:
        # Read YAML config file
        with open(path) as f:
            raw = yaml.safe_load(f)

        # Validate required sections
        ConfigLoader._validate(raw)
        return raw

    @staticmethod
    def _validate(raw: dict) -> None:
        # Check required keys
        required_sections = ['data', 'model']
        for section in required_sections:
            if section not in raw:
                raise ValueError(f"Missing config section: '{section}'")

        # Validate data section
        data = raw['data']
        required_data = ['raw_path', 'split_path', 'img_size', 'batch_size']
        for key in required_data:
            if key not in data:
                raise ValueError(f"Missing data config: '{key}'")

        # Validate image dimensions
        if len(data['img_size']) != 2:
            raise ValueError("img_size must have exactly 2 values: [H, W]")

        # Validate split ratios
        if 'split_ratio' in data:
            ratios = data['split_ratio']
            total = sum(ratios.values())
            if abs(total - 1.0) > 0.01:
                raise ValueError(f"Split ratios must sum to 1.0, got {total}")

        # Validate model section
        model = raw['model']
        required_model = ['base_model', 'learning_rate_stage1', 'learning_rate_stage2',
                          'epochs_stage1', 'epochs_stage2']
        for key in required_model:
            if key not in model:
                raise ValueError(f"Missing model config: '{key}'")
