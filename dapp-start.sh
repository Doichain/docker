#!/usr/bin/env bash
#(cd /home/doichain/dapp; meteor run --settings /home/doichain/data/dapp/settings.json)

#echo 'starting creating bundle $DAPP_HOST:$DAPP_PORT' && cd dapp && rm -rf build
#meteor build build/ --architecture os.linux.x86_64 --directory #--server $DAPP_HOST:$DAPP_PORT
#echo 'finished creating bundle' && cd build/bundle/programs/server && npm install && cd -
echo 'starting doichain dapp via node' && export METEOR_SETTINGS=$(cat /home/doichain/data/dapp/settings.json) && export PORT=3000
export ROOT_URL=$DAPP_HOST:$DAPP_PORT && export MONGO_URL=mongodb://mongo:27017/doichain


echo "starting dapp via node"
(cd /home/doichain/dapp; nohup node build/bundle/main.js &)
