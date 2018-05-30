#!/bin/bash
set -euo pipefail

<<<<<<< Updated upstream
scripts/namecoin-start.sh &
scripts/dapp-start.sh &
=======
scripts/doichain-start.sh &
>>>>>>> Stashed changes

exec /bin/bash