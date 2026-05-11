#!/usr/bin/env bash
# Railway web-service start: keep the gateway running, and expose the dashboard
# as the foreground process on Railway's assigned HTTP port.
set -euo pipefail

hermes gateway run &

exec hermes dashboard --insecure --host 0.0.0.0 --port "${PORT:-9119}" --no-open
