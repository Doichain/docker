FROM ubuntu

#Setup build vars
ARG OS_LOCALE=en_US.UTF-8
ARG LANG=${OS_LOCALE}
ARG LANGUAGE=en_US:en
ARG LC_ALL=${OS_LOCALE}

#Setup run vars
ENV CONNECTION_NODE 5.9.154.226
ENV DAPP_CONFIRM false
ENV DAPP_PORT 3000
ENV DAPP_SEND false
ENV DAPP_VERIFY false
ENV MAX_CONNECTIONS 5
ENV NODE_PORT 8338
ENV REGTEST false
ENV RPC_ALLOW_IP ::/0
ENV RPC_PASSWORD Password
ENV RPC_PORT 8339
ENV RPC_USER Admin

#Install dependencies
RUN apt-get update && apt-get install -y \
	autoconf \
	bsdmainutils \
	build-essential \
	curl \
	dos2unix \
	git \
	libboost-all-dev \
	libevent-dev \
	libssl-dev \
	libtool \
	locales \
	pkg-config \
	sudo \
	&& rm -rf /var/lib/apt/lists/*

#Install locales
RUN locale-gen ${OS_LOCALE}

#Set user
WORKDIR /
RUN adduser --disabled-password --gecos '' doichain && \
	adduser doichain sudo && \
	echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER doichain

#Install berkeley-db
WORKDIR /tmp/build/bdb
ADD http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz db-4.8.30.NC.tar.gz
RUN echo '12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef  db-4.8.30.NC.tar.gz' | sudo sha256sum -c && \
	sudo tar xzvf db-4.8.30.NC.tar.gz && \
	cd db-4.8.30.NC/build_unix/ && \
	sudo ../dist/configure --enable-cxx && \
	sudo make && \
	sudo make install && \
	sudo ln -s /usr/local/BerkeleyDB.4.8 /usr/include/db4.8 &&\
	sudo ln -s /usr/include/db4.8/include/* /usr/include &&\
	sudo ln -s /usr/include/db4.8/lib/* /usr/lib

#Install namecoin-core
WORKDIR /home/doichain
RUN mkdir .namecoin && \
	sudo git clone --branch 'doichain2' https://github.com/Le-Space/namecoin-core.git namecoin-core && \
	cd namecoin-core && \
	sudo ./autogen.sh && \
	sudo ./configure --without-gui && \
	sudo make && \
	sudo make install

RUN sudo curl https://install.meteor.com/ | sh && \
	sudo git clone https://github.com/Doichain/dApp.git /home/doichain/dapp && \
	sudo chown -R doichain:doichain /home/doichain/dapp
WORKDIR /home/doichain/dapp/
RUN meteor npm install && \
	sudo meteor npm install --save bcrypt

#Copy start scripts
WORKDIR /home/doichain/scripts/
COPY entrypoint.sh entrypoint.sh
COPY start.sh start.sh
COPY namecoin-start.sh namecoin-start.sh
COPY dapp-start.sh dapp-start.sh
RUN sudo dos2unix \
	entrypoint.sh \
	start.sh \
	namecoin-start.sh \
	dapp-start.sh && \
	sudo apt-get --purge remove -y dos2unix && \
	sudo rm -rf /var/lib/apt/lists/*

#Create data dir
WORKDIR /home/doichain
RUN mkdir data && \
	cd data && \
	mkdir \
	namecoin \
	dapp

#Run entrypoint
WORKDIR /home/doichain
ENTRYPOINT ["scripts/entrypoint.sh"]

#Start namecoin and meteor
CMD ["scripts/start.sh"]

#Expose ports
EXPOSE $DAPP_PORT $NODE_PORT
