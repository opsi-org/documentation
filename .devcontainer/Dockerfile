FROM debian:buster AS opsidoc-dev-container

LABEL maintainer Fabian Kalweit <f.kalweit@uib.de>


ARG USER
ENV USER=${USER}

ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG USERNAME=${USER}


	

ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update && apt install -y gcc \
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
	vim

RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
	&& sudo apt install -y nodejs

RUN gem install asciidoctor \
	&& gem install compass \
	&& gem install prawn-gmagick \
	&& gem install zurb-foundation \
	&& gem install asciidoctor-pdf -v 1.6 \
	&& gem install  asciidoctor-interdoc-reftext \
	&& gem install sass \
	&& gem install rouge

# RUN groupmod -n $USERNAME $(getent group 1000 | awk -F ":" '{ print $1 }') \
# 	&& mv /home/$(getent passwd 1000 | awk -F ":" '{ print $1 }') /home/$USERNAME \
# 	&& ln -s /home/$USERNAME /home/$(getent passwd 1000 | awk -F ":" '{ print $1 }') \
# 	&& usermod -l $USERNAME $(getent passwd 1000 | awk -F ":" '{ print $1 }') \
# 	&& usermod --uid $USER_UID --gid $USER_GID $USERNAME \
# 	&& chown -R $USER_UID:$USER_GID /home/$USERNAME

RUN groupadd --gid $USER_GID $USERNAME \
	&& useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
	&& apt-get update \
	&& apt-get install -y sudo \
	&& echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
	&& chmod 0440 /etc/sudoers.d/$USERNAME


WORKDIR /home

USER $USERNAME