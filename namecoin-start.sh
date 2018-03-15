_REGTEST=''
if [ $REGTEST = true ]; then
	_REGTEST='-regtest' 
fi

namecoind $_REGTEST -datadir='/home/doichain/data/namecoin' -addnode=$CONNECTION_NODE
