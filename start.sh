#!/bin/bash
set -euo pipefail

scripts/namecoin-start.sh &
scripts/dapp-start.sh &

exec /bin/bash