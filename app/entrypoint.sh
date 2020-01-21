#!/usr/bin/env bash
set -euo pipefail

exec rackup -p 8080 -o 0.0.0.0
