_REGTEST=''
if [ $REGTEST = true ]; then
	_REGTEST='-regtest'
fi

namecoind $_REGTEST -addnode=$CONNECTION_NODE
