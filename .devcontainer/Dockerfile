FROM debian:buster AS opsidoc-asciidoctor

LABEL maintainer Fabian Kalweit <f.kalweit@uib.de>

ARG USER

ENV USER=${USER}

ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update && apt install -y asciidoctor \
	graphicsmagick \
	libgraphicsmagick++1-dev \
	libgraphicsmagick1-dev \
	graphicsmagick-libmagick-dev-compat \
	ruby \
	ruby-dev \
	musl-dev \
	gcc \
	git \
	bash-completion \
	sudo \
	make \
	python2 \
	python3 \
	build-essential \
	curl \
	vim

RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
	&& sudo apt install -y nodejs

RUN gem install sass \
	&& gem install compass \
	&& gem install prawn-gmagick \
	&& gem install zurb-foundation \
	&& gem install asciidoctor-epub3 \
	&& gem install asciidoctor-pdf \
	&& gem install rouge

RUN if [ -z ${USER+x} ]; then \
	echo "var USER is unset"; \
	else \
		useradd --create-home -s /bin/bash ${USER} \
		&& adduser ${USER} sudo \
		&& echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers; \
	fi


WORKDIR /home
