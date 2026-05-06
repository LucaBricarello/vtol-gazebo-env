FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    lsb-release \
    gnupg \
    git \
    build-essential \
    cmake \
    wget \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN curl https://packages.osrfoundation.org/gazebo.gpg --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null && \
    apt-get update && apt-get install -y gz-harmonic \
    && rm -rf /var/lib/apt/lists/*

# Fix dipendenze OpenCV e GStreamer
RUN apt-get update && apt-get install -y \
    libgz-sim8-dev \
    rapidjson-dev \
    libopencv-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    && rm -rf /var/lib/apt/lists/*

ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} devuser && \
    useradd -u ${UID} -g ${GID} -ms /bin/bash devuser && \
    echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER devuser
WORKDIR /home/devuser

RUN curl -fsSL https://pixi.sh/install.sh | bash
ENV PATH="/home/devuser/.pixi/bin:${PATH}"

WORKDIR /workspace
# Scarica TUTTI e 3 i repository necessari
RUN git clone https://github.com/ArduPilot/ardupilot_gazebo.git && \
    git clone --recurse-submodules https://github.com/ArduPilot/ardupilot.git && \
    git clone https://github.com/ArduPilot/SITL_Models.git
