FROM debian:bookworm AS opsidoc-antora

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
		vim \
	&& apt clean

RUN curl -fsSL https://deb.nodesource.com/setup_19.x | bash - \
	&& sudo apt install -y nodejs \
	&& npm install --global npm \
	&& npm install --global gulp gulp-cli

RUN gem install asciidoctor \
	&& gem install compass \
	&& gem install prawn-gmagick \
	&& gem install public_suffix \
	&& gem install zurb-foundation \
	&& gem install asciidoctor-pdf \
	&& gem install asciidoctor-interdoc-reftext \
	&& gem install sass \
	&& gem install rouge

WORKDIR /home
