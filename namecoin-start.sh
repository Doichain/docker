_REGTEST=''
if [ $REGTEST = true ]; then
	_REGTEST='-regtest -addnode='$CONNECTION_NODE
fi

namecoind $_REGTEST
