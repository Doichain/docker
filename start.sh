#!/bin/bash
set -euo pipefail

exec scripts/namecoin-start.sh &
exec scripts/dapp-start.sh &

exec /bin/bash