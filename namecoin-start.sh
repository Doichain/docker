NAMECOIN_START="namecoind"
if [ $REGTEST == 'true' ]; then
  NAMECOIN_START=$NAMECOIN_START" -regtest"
fi
NAMECOIN_START=$NAMECOIN_START" -printtoconsole -datadir=/home/doichain/data/namecoin"
exec $NAMECOIN_START