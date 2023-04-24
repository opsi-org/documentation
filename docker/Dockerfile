FROM debian:bullseye AS opsidoc-antora

LABEL maintainer Fabian Kalweit <f.kalweit@uib.de>

ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
	&& echo $TZ > /etc/timezone

RUN apt update \
	&& apt install -y \
		gcc \
		git \
		bash-completion \
		sudo \
		make \
		python2 \
		python3 \
		build-essential \
		curl \
		ruby \
		ruby-dev \
		graphicsmagick \
		libgraphicsmagick++1-dev \
		libgraphicsmagick1-dev \
		graphicsmagick-libmagick-dev-compat \
		musl-dev \
		gcc \
		vim \
	&& apt clean

RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
	&& sudo apt install -y nodejs \
	&& npm -g config set user root \
	&& npm install --global npm \
	&& npm install --global gulp gulp-cli

RUN gem install asciidoctor \
	&& gem install compass \
	&& gem install prawn-gmagick \
	&& gem install public_suffix -v 4.0.7 \
	&& gem install zurb-foundation \
	&& gem install asciidoctor-pdf -v 1.6 \
	&& gem install asciidoctor-interdoc-reftext \
	&& gem install sass \
	&& gem install rouge

WORKDIR /home
