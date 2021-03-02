FROM ubuntu:bionic

LABEL maintainer Erol Ueluekmen <e.ueluekmen@uib.de>

ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update && apt install -y asciidoc \
aspell \
texlive-lang-german \
texlive-lang-english \
texlive-lang-french \
lmodern texlive-extra-utils \
make
WORKDIR /root

