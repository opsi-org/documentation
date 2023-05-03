FROM docker.uib.gmbh/opsi/opsidoc-antora:bookworm AS opsidoc-dev-container

LABEL maintainer Fabian Kalweit <f.kalweit@uib.de>



ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG USERNAME=opsidoc


RUN groupadd --gid $USER_GID $USERNAME \
	&& useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
	&& apt-get update \
	&& apt-get install -y sudo \
	&& echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
	&& chmod 0440 /etc/sudoers.d/$USERNAME


WORKDIR /home

USER $USERNAME
