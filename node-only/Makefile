IMG=doichain/node-only
# DOICHAIN_VER=dc0.16.3.1
DOICHAIN_VER=dc0.20.1.11
default: build

build:
	docker build --no-cache -t $(IMG) --build-arg DOICHAIN_VER=$(DOICHAIN_VER) .

build-no-clean:
	docker build -t $(IMG) --build-arg DOICHAIN_VER=$(DOICHAIN_VER) .



