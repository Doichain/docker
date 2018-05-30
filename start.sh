#!/bin/bash
set -euo pipefail

scripts/dapp-start.sh &
scripts/doichain-start.sh &

exec /bin/bash