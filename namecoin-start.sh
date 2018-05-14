_REGTEST=''
if [ $REGTEST = true ]; then
<<<<<<< HEAD
	_REGTEST='-regtest'
fi

namecoind $_REGTEST -addnode=$CONNECTION_NODE
=======
	_REGTEST='-regtest -addnode='$CONNECTION_NODE
fi

_TESTNET=''
if [ $TESTNET = true ]; then
	_TESTNET='-testnet -addnode='$CONNECTION_NODE
fi

namecoind $_REGTEST $_TESTNET
>>>>>>> 0.0.4
