#!/bin/sh

PID_FILE="/tmp/git_repo_watch.pid"

if [ ! -f "$PID_FILE" ]; then
	echo "No watcher PID file found."
	exit 1
fi

WATCH_PID=$(cat "$PID_FILE")

pkill -TERM -P "$WATCH_PID"
kill "$WATCH_PID"
rm -f "$PID_FILE"

echo "Git watcher stopped."
