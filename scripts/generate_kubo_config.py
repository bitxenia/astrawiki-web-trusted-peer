import json
import os


# Step 1: Read .env file
def read_env_file(filepath=".env"):
    env_vars = {}
    with open(filepath, "r") as file:
        for line in file:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            key, _, value = line.partition("=")
            env_vars[key.strip()] = value.strip()
    return env_vars


# Step 2: Load config file
def load_config(filepath="configuration/kubo_config/config"):
    with open(filepath, "r") as file:
        return json.load(file)


# Step 3: Write updated config
def write_config(data, filepath="./data/kubo_config/config"):
    # Create directory if it doesn't exist
    os.makedirs(os.path.dirname(filepath), exist_ok=True)

    # Write the updated config to the file
    with open(filepath, "w") as file:
        json.dump(data, file, indent=2)


# Main logic
def inject_identity():
    env = read_env_file()
    config = load_config()

    peer_id = env.get("PEER_ID")
    priv_key = env.get("PRIV_KEY")

    if not peer_id or not priv_key:
        raise ValueError("Missing PEER_ID or PRIV_KEY in .env file.")

    config["Identity"]["PeerID"] = peer_id
    config["Identity"]["PrivKey"] = priv_key

    write_config(config)
    print("Config updated successfully with Identity values.")


if __name__ == "__main__":
    inject_identity()
