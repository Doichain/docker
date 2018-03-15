#!/bin/bash
set -euo pipefail

scripts/namecoin-start.sh &

exec /bin/bash
