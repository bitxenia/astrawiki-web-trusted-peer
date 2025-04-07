import shutil
import json
import os
from pathlib import Path

# -----------------------------
# File Paths
# -----------------------------

SERVICE_SRC = Path("./configuration/ipfs_cluster_config/service.json")
SERVICE_DEST = Path("./data/ipfs_cluster_data/service.json")
IDENTITY_SRC = Path("./configuration/ipfs_cluster_config/identity.json")
IDENTITY_DEST = Path("./data/ipfs_cluster_data/identity.json")
ENV_FILE = Path(".env")

# -----------------------------
# File Utilities
# -----------------------------


def ensure_directory_exists(path: Path):
    path.parent.mkdir(parents=True, exist_ok=True)


def copy_file(src: Path, dest: Path):
    ensure_directory_exists(dest)
    shutil.copy2(src, dest)
    print(f"Copied {src} to {dest}")


# -----------------------------
# Identity Configuration
# -----------------------------


def read_env_file(filepath: Path) -> dict:
    env_vars = {}
    with filepath.open("r") as file:
        for line in file:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            key, _, value = line.partition("=")
            env_vars[key.strip()] = value.strip()
    return env_vars


def load_json(filepath: Path) -> dict:
    with filepath.open("r") as file:
        return json.load(file)


def write_json(data: dict, filepath: Path):
    ensure_directory_exists(filepath)
    with filepath.open("w") as file:
        json.dump(data, file, indent=2)


def inject_identity():
    env = read_env_file(ENV_FILE)
    config = load_json(IDENTITY_SRC)

    peer_id = env.get("ID")
    priv_key = env.get("PRIVATE_KEY")

    if not peer_id or not priv_key:
        raise ValueError("Missing ID or PRIVATE_KEY in .env file.")

    config["id"] = peer_id
    config["private_key"] = priv_key

    write_json(config, IDENTITY_DEST)
    print("Config updated successfully with identity values.")


# -----------------------------
# Main
# -----------------------------

if __name__ == "__main__":
    copy_file(SERVICE_SRC, SERVICE_DEST)
    inject_identity()
