FROM ubuntu

ARG DOICHAIN_VER=master
ENV DOICHAIN_VER $DOICHAIN_VER

ARG OS=win64
ENV OS $OS

#Install dependencies
RUN apt-get update && apt-get install -y \
	autoconf \
	apt-utils \
	bsdmainutils \
	build-essential \
	curl \
	jq \
	vim \
	jq \
	bc \
	bsdtar \
	dos2unix \
	git \
	libboost-all-dev \
	libevent-dev \
	libssl-dev \
	libtool \
	locales \
	pkg-config \
	sudo \
	autotools-dev \
	automake \
	pkg-config \
	bsdmainutils \
	g++-mingw-w64-i686 mingw-w64-i686-dev \
	&& update-alternatives --set i686-w64-mingw32-g++ /usr/bin/i686-w64-mingw32-g++-posix \
	&& rm -rf /var/lib/apt/lists/* \


#Install berkeley-db
WORKDIR /usr/src
ADD http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz db-4.8.30.NC.tar.gz
RUN echo '12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef  db-4.8.30.NC.tar.gz' | sudo sha256sum -c && \
	tar xzvf db-4.8.30.NC.tar.gz && \
	cd db-4.8.30.NC/build_unix/ && \
	../dist/configure --enable-cxx && \
	make && \
	make install && \
	ln -s /usr/local/BerkeleyDB.4.8 /usr/include/db4.8 && \
	ln -s /usr/include/db4.8/include/* /usr/include && \
	ln -s /usr/include/db4.8/lib/* /usr/lib &&\
	git clone --branch ${DOICHAIN_VER} --depth 1 https://github.com/Doichain/core.git doichain-core && \
	PATH=$(echo "$PATH" | sed -e 's/:\/mnt.*//g') &&\
	cd depends &&\
	make HOST=x86_64-w64-mingw32 &&\
	cd .. &&\
	cd doichain-core && \
	./autogen.sh && \
	CONFIG_SITE=$PWD/depends/i686-w64-mingw32/share/config.site ./configure --prefix=/ && \
	make  && \
	find . -name *.exe && \



