IMG=doichain/crosscompile
DOICHAIN_VER=0.0.5

#osx win64 win32 
OS=osx

default: build

check:
	which jq; which bc

help:
	$(info Usage: make build)
	$(info 		  make clean - removes $(IMG) image and containers)

all: build

build:
	docker build  -t $(IMG) --build-arg DOICHAIN_VER=$(DOICHAIN_VER) --build-arg OS=$(OS) .
connect: docker run -td $(IMG) bash
	
