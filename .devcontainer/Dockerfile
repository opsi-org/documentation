FROM asciidoctor/docker-asciidoctor AS opsidoc-asciidoctor

LABEL maintainer Fabian Kalweit <f.kalweit@uib.de>

ARG USER

ENV USER=${USER}

ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apk add --no-cache python2 python3 py3-pip \
	git bash-completion sudo make \
	graphicsmagick-dev ruby-dev musl-dev gcc && \
	gem install prawn-gmagick

RUN echo $USER
RUN echo "test"
RUN if [ -z ${USER+x} ]; then \
		echo "var USER is unset"; \
	elif [ ${USER} == "root" ]; then \
		echo "var USER is root"; \
	else \
		echo ${USER} \
		adduser --disabled-password ${USER} \
		&& echo "$USER ALL=(ALL) ALL" > /etc/sudoers.d/$USER \
		&& chmod 0440 /etc/sudoers.d/$USER; \
	fi


WORKDIR /home

