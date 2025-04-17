#!/bin/bash
set -ex

echo "Starting entrypoint script..."
echo "Launching iris-main..."

/iris-main &
IRIS_PID=$!

echo "iris-main started with PID $IRIS_PID. Executing CMD arguments: $@"
exec "$@"
