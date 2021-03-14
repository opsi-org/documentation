FROM ubuntu:focal

LABEL maintainer Erol Ueluekmen <e.ueluekmen@uib.de>

ARG USER

ENV USER=${USER}

ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update && apt install -y asciidoc \
aspell \
texlive-lang-german \
texlive-lang-english \
texlive-lang-french \
lmodern texlive-extra-utils \
git \
make

RUN if [ -z ${USER+x} ]; then echo "var USER is unset"; else useradd --create-home -s /bin/bash ${USER}; fi


WORKDIR /root

