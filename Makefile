IMG=doichain/node-only
DOICHAIN_VER=0.0.5

default: build

build:
	docker build --no-cache -t $(IMG) --build-arg DOICHAIN_VER=$(DOICHAIN_VER) .


