# doichain/node-only docker image 
### a Doichain node (without integrated Doichain dApp)

### Installation
1. clone this repository ```git clone https://github.com/Doichain/docker.git doichain-docker```
2. build docker image 
```
cd doichain-docker/node-only
docker build --no-cache -t dc0.16.3.1 --build-arg DOICHAIN_VER=doichain/node-only .
```
3. Run docker image 
Parameters:

* ``-e RPC_PASSWORD`` (optional) - if not given it will be generated on start
```
docker run -it -e TESTNET=true -p 18339:18339 -e RPC_PASSWORD=<my-rpc-password> --name doichain-testnet doichain/node-only
```
4. Connect into docker container and check if node connects to testnet
```
docker exec -it doichain-testnet doichain-cli -getinfo
```
