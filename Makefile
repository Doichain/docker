IMG=doichain/node-only
#IMG=doichain/core:0.16.3.1
DOICHAIN_VER=0.16.3.1

default: build

build:
	docker build --no-cache -t $(IMG) --build-arg DOICHAIN_VER=$(DOICHAIN_VER) .


