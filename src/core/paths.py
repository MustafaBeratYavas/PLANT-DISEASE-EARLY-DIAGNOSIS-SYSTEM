import os


class PathManager:
    def __init__(self, config: dict, base_root: str = "outputs") -> None:
        # Initialize base paths
        self.base_dir = base_root
        self.version_dir = self._get_next_version()
        self._create_dirs()

    def _get_next_version(self) -> str:
        # Create output directory
        if not os.path.exists(self.base_dir):
            os.makedirs(self.base_dir)

        # Find existing versions
        existing = [d for d in os.listdir(self.base_dir) if d.startswith("model_v")]

        if not existing:
            return os.path.join(self.base_dir, "model_v1")

        # Parse version numbers
        versions = []
        for d in existing:
            try:
                v_num = int(d.split("model_v")[1])
                versions.append(v_num)
            except (IndexError, ValueError):
                continue

        if not versions:
            return os.path.join(self.base_dir, "model_v1")

        # Return next version
        return os.path.join(self.base_dir, f"model_v{max(versions) + 1}")

    def _create_dirs(self) -> None:
        # Create output subdirectories
        for d in ["checkpoints", "figures", "tables"]:
            os.makedirs(os.path.join(self.version_dir, d), exist_ok=True)
