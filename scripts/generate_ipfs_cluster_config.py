import shutil
from pathlib import Path

# Define source and destination paths
source = Path("./configuration/ipfs_cluster_config/service.json")
destination = Path("./data/ipfs_cluster_data/service.json")

# Make sure destination folder exists
destination.parent.mkdir(parents=True, exist_ok=True)

# Copy the file
shutil.copy2(source, destination)

print(f"Copied {source} to {destination}")
