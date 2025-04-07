#!/bin/sh

SCRIPT_PATH="./scripts/build_static_files.sh"
INTERVAL_SECONDS=60
PID_FILE="/tmp/git_repo_watch.pid"

# Check if already running
if [ -f "$PID_FILE" ]; then
	EXISTING_PID=$(cat "$PID_FILE")
	if [ -d "/proc/$EXISTING_PID" ] && grep -q "watch_build.sh" "/proc/$EXISTING_PID/cmdline"; then
		echo "Already running with PID $EXISTING_PID"
		exit 1
	else
		echo "Stale PID file found. Cleaning up."
		rm -f "$PID_FILE"
	fi
fi

# Write current PID to file
echo $$ >"$PID_FILE"

# Clean up PID file on exit
trap 'rm -f "$PID_FILE"; exit' INT TERM EXIT

echo "Git watcher started with PID $$. Running every ${INTERVAL_SECONDS} seconds..."

while true; do
	echo "Running git watcher at $(date)"
	if ! sh "$SCRIPT_PATH"; then
		echo "Build script failed at $(date)"
	fi
	sleep "$INTERVAL_SECONDS"
done
