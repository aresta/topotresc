FROM ubuntu:21.10
MAINTAINER arestabrucs
# Based on instructions from: https://wiki.openstreetmap.org/wiki/Mod_tile#Install_mod_tile_From_Source
# and ideas from https://github.com/jimmyrocks/osm-tiles-mapnik

ENV DEBIAN_FRONTEND=nonintercative
RUN apt-get update -qq && apt-get install  -y --no-install-recommends \
    curl \
    git \
    wget \
    zip unzip \
    gpg-agent \
    python3-mapnik \
    mapnik-utils \
    python-is-python3 \
    python3-queuelib \
    python3-pip \
    npm \
    osm2pgsql \
    osmium-tool \
    software-properties-common \
    build-essential \
    gdal-bin \
    fonts-noto-cjk fonts-noto-hinted fonts-noto-unhinted \
    ttf-unifont fonts-hanazono \
  && npm install -g npm \
  && npm install -g carto \
  && pip install pillow \
  && rm -rf /var/lib/apt/lists/*