IMG=doichain/node-only
DOICHAIN_VER=0.0.6

default: build

build:
	docker build --no-cache -t $(IMG) --build-arg DOICHAIN_VER=$(DOICHAIN_VER) .


